#
# Copyright 2015, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/json_compat'
require 'chef/provider/package'
require 'chef/resource/package'
require 'poise'

require 'poise_javascript/error'
require 'poise_javascript/javascript_command_mixin'


module PoiseJavascript
  module Resources
    # (see NodePackage::Resource)
    # @since 1.0.0
    module NodePackage
      # A `node_package` resource to manage Node.js packages using npm.
      #
      # @provides node_package
      # @action install
      # @action upgrade
      # @action uninstall
      # @example
      #   node_package 'express' do
      #     javascript '0.10'
      #     version '1.8.3'
      #   end
      class Resource < Chef::Resource::Package
        include PoiseJavascript::JavascriptCommandMixin
        provides(:node_package)
        # Manually create matchers because #actions is unreliable.
        %i{install upgrade remove}.each do |action|
          Poise::Helpers::ChefspecMatchers.create_matcher(:node_package, action)
        end

        # @!attribute group
        #   System group to install the package.
        #   @return [String, Integer, nil]
        attribute(:group, kind_of: [String, Integer, NilClass])
        # @!attribute path
        #   Path to install the package in to. If unset install using --global.
        #   @return [String, nil, false]
        attribute(:path, kind_of: [String, NilClass, FalseClass])
        # @!attribute unsafe_perm
        #   Enable --unsafe-perm.
        #   @return [Boolean, nil]
        attribute(:unsafe_perm, equal_to: [true, false, nil], default: true)
        # @!attribute user
        #   System user to install the package.
        #   @return [String, Integer, nil]
        attribute(:user, kind_of: [String, Integer, NilClass])

        def initialize(*args)
          super
          # For older Chef.
          @resource_name = :node_package
          # We don't have these actions.
          @allowed_actions.delete(:purge)
          @allowed_actions.delete(:reconfig)
        end

        # Upstream attribute we don't support. Sets are an error and gets always
        # return nil.
        #
        # @api private
        # @param arg [Object] Ignored
        # @return [nil]
        def response_file(arg=nil)
          raise NoMethodError if arg
        end

        # (see #response_file)
        def response_file_variables(arg=nil)
          raise NoMethodError if arg && arg != {}
        end
      end

      # The default provider for the `node_package` resource.
      #
      # @see Resource
      class Provider < Chef::Provider::Package
        include PoiseJavascript::JavascriptCommandMixin
        provides(:node_package)

        # Load current and candidate versions for all needed packages.
        #
        # @api private
        # @return [Chef::Resource]
        def load_current_resource
          @current_resource = new_resource.class.new(new_resource.name, run_context)
          current_resource.package_name(new_resource.package_name)
          check_package_versions(current_resource)
          current_resource
        end

        # Populate current and candidate versions for all needed packages.
        #
        # @api private
        # @param resource [PoiseJavascript::Resources::NodePackage::Resource]
        #   Resource to load for.
        # @return [void]
        def check_package_versions(resource)
          version_data = Hash.new {|hash, key| hash[key] = {current: nil, candidate: nil} }
          # Get the version for everything currently installed.
          list_args = npm_version?('>= 1.4.16') ? %w{--depth 0} : []
          npm_shell_out!('list', list_args).fetch('dependencies', {}).each do |pkg_name, pkg_data|
            version_data[pkg_name][:current] = pkg_data['version']
          end
          # If any requested packages are currently installed, run npm outdated
          # to look for candidate versions. Older npm doesn't support --json
          # here so you get slow behavior, sorry.
          requested_packages = Set.new(Array(resource.package_name))
          if npm_version?('>= 1.3.16') && version_data.any? {|pkg_name, _pkg_vers| requested_packages.include?(pkg_name) }
            outdated = npm_shell_out!('outdated') || {}
            version_data.each do |pkg_name, pkg_vers|
              pkg_vers[:candidate] = if outdated.include?(pkg_name)
                outdated[pkg_name]['wanted']
              else
                # If it was already installed and not listed in outdated, it
                # must have been up to date already.
                pkg_vers[:current]
              end
            end
          end
          # Check for candidates for anything else we didn't get from outdated.
          requested_packages.each do |pkg_name|
            version_data[pkg_name][:candidate] ||= npm_shell_out!('show', [pkg_name])['version']
          end
          # Populate the current resource and candidate versions. Youch this is
          # a gross mix of data flow.
          if(resource.package_name.is_a?(Array))
            @candidate_version = []
            versions = []
            [resource.package_name].flatten.each do |name|
              ver = version_data[name.downcase]
              versions << ver[:current]
              @candidate_version << ver[:candidate]
            end
            resource.version(versions)
          else
            ver = version_data[resource.package_name.downcase]
            resource.version(ver[:current])
            @candidate_version = ver[:candidate]
          end
        end

        # Install package(s) using npm.
        #
        # @param name [String, Array<String>] Name(s) of package(s).
        # @param version [String, Array<String>] Version(s) of package(s).
        # @return [void]
        def install_package(name, version)
          args = []
          # Set --unsafe-perm unless the property is nil.
          unless new_resource.unsafe_perm.nil?
            args << '--unsafe-perm'
            args << new_resource.unsafe_perm.to_s
          end
          # Build up the actual package install args.
          if new_resource.source
            args << new_resource.source
          else
            Array(name).zip(Array(version)) do |pkg_name, pkg_ver|
              args << "#{pkg_name}@#{pkg_ver}"
            end
          end
          npm_shell_out!('install', args, parse_json: false)
        end

        # Upgrade and install are the same for NPM.
        alias_method :upgrade_package, :install_package

        # Uninstall package(s) using npm.
        #
        # @param name [String, Array<String>] Name(s) of package(s).
        # @param version [String, Array<String>] Version(s) of package(s).
        # @return [void]
        def remove_package(name, version)
          npm_shell_out!('uninstall', [name].flatten, parse_json: false)
        end

        private

        # Run an npm command.
        #
        # @param subcmd [String] Subcommand to run.
        # @param args [Array<String>] Command arguments.
        # @param parse_json [Boolean] Parse the JSON on stdout.
        # @return [Hash]
        def npm_shell_out!(subcmd, args=[], parse_json: true)
          cmd = [new_resource.npm_binary, subcmd, '--json']
          # If path is nil, we are in global mode.
          cmd << '--global' unless new_resource.path
          # Add the rest.
          cmd.concat(args)
          # If we are in global mode, cwd will be nil so probably just fine. Add
          # the directory for the node binary to $PATH for post-install stuffs.
          new_path = [::File.dirname(new_resource.javascript), ENV['PATH'].to_s].join(::File::PATH_SEPARATOR)
          out = javascript_shell_out!(cmd, cwd: new_resource.path, group: new_resource.group, user: new_resource.user, environment: {'PATH' => new_path})
          if parse_json
            # Parse the JSON.
            if out.stdout.strip.empty?
              {}
            else
              Chef::JSONCompat.parse(out.stdout)
            end
          else
            out
          end
        end

        # Find the version of the current npm binary.
        #
        # @return [Gem::Version]
        def npm_version
          @npm_version ||= begin
            out = javascript_shell_out!([new_resource.npm_binary, 'version'])
            # Older NPM doesn't support --json here we get to regex!
            # The line we want looks like:
            # npm: '2.12.1'
            if out.stdout =~ /npm: '([^']+)'/
              Gem::Version.new($1)
            else
              raise PoiseJavascript::Error.new("Unable to parse NPM version from #{out.stdout.inspect}")
            end
          end
        end

        # Check the NPM version against a requirement.
        #
        # @param req [String] Requirement string in Gem::Requirement format.
        # @return [Boolean]
        def npm_version?(req)
          Gem::Requirement.new(req).satisfied_by?(npm_version)
        end

      end
    end
  end
end
