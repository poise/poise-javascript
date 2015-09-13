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

require 'chef/provider'
require 'chef/resource'
require 'poise'

require 'poise_javascript/javascript_command_mixin'


module PoiseJavascript
  module Resources
    # (see NpmInstall::Resource)
    # @since 1.0.0
    module NpmInstall
      # A `npm_install` resource to install NPM packages based on a package.json.
      #
      # @provides npm_install
      # @action install
      # @example
      #   npm_install '/opt/myapp'
      class Resource < Chef::Resource
        include PoiseJavascript::JavascriptCommandMixin
        provides(:npm_install)
        actions(:install)

        # @!attribute path
        #   Directory to run `npm install` from.
        #   @return [String]
        attribute(:path, kind_of: String, name_attribute: true)
        # @!attribute group
        #   System group to install the packages.
        #   @return [String, Integer, nil]
        attribute(:group, kind_of: [String, Integer, NilClass])
        # @!attribute production
        #   Enable production install mode.
        #   @return [Boolean]
        attribute(:production, equal_to: [true, false], default: true)
        # @!attribute unsafe_perm
        #   Enable --unsafe-perm.
        #   @return [Boolean, nil]
        attribute(:unsafe_perm, equal_to: [true, false, nil], default: true)
        # @!attribute user
        #   System user to install the packages.
        #   @return [String, Integer, nil]
        attribute(:user, kind_of: [String, Integer, NilClass])
      end

      # The default provider for `npm_install`.
      #
      # @see Resource
      # @provides npm_install
      class Provider < Chef::Provider
        include Poise
        include PoiseJavascript::JavascriptCommandMixin
        provides(:npm_install)

        # The `install` action for the `npm_install` resource.
        #
        # @return [void]
        def action_install
          cmd = [new_resource.npm_binary, 'install']
          cmd << '--production' if new_resource.production
          # Set --unsafe-perm unless the property is nil.
          unless new_resource.unsafe_perm.nil?
            cmd << '--unsafe-perm'
            cmd << new_resource.unsafe_perm.to_s
          end
          # Add the directory for the node binary to $PATH for post-install stuffs.
          new_path = [::File.dirname(new_resource.javascript), ENV['PATH'].to_s].join(::File::PATH_SEPARATOR)
          output = javascript_shell_out!(cmd, cwd: new_resource.path, user: new_resource.user, group: new_resource.group, environment: {'PATH' => new_path}).stdout
          unless output.strip.empty?
            # Any output means it did something.
            new_resource.updated_by_last_action(true)
          end
        end

      end
    end
  end
end
