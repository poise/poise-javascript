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


module PoiseJavascript
  module Resources
    # (see JavascriptRuntimeTest::Resource)
    # @since 1.0.0
    # @api private
    module JavascriptRuntimeTest
      # A `javascript_runtime_test` resource for integration testing of this
      # cookbook. This is an internal API and can change at any time.
      #
      # @provides javascript_runtime_test
      # @action run
      class Resource < Chef::Resource
        include Poise
        provides(:javascript_runtime_test)
        actions(:run)

        attribute(:version, kind_of: String, name_attribute: true)
        attribute(:runtime_provider, kind_of: Symbol)
        attribute(:path, kind_of: String, default: lazy { default_path })
        attribute(:test_yo, equal_to: [true, false], default: true)

        def default_path
          ::File.join('', 'root', "javascript_test_#{name}")
        end
      end

      # The default provider for `javascript_runtime_test`.
      #
      # @see Resource
      # @provides javascript_runtime_test
      class Provider < Chef::Provider
        include Poise
        provides(:javascript_runtime_test)

        # The `run` action for the `javascript_runtime_test` resource.
        #
        # @return [void]
        def action_run
          notifying_block do
            # Top level directory for this test.
            directory new_resource.path

            # Install and log the version.
            javascript_runtime new_resource.name do
              provider new_resource.runtime_provider if new_resource.runtime_provider
              version new_resource.version
            end
            test_version

            # Create a package and test npm_install.
            pkg_path = ::File.join(new_resource.path, 'pkg')
            directory pkg_path
            file ::File.join(pkg_path, 'package.json') do
              content <<-EOH
{
  "name": "mypkg",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \\"Error: no test specified\\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "4.13.3"
  },
  "devDependencies": {
    "handlebars": "4.0.2"
  }
}
EOH
            end
            npm_install pkg_path do
              notifies :create, sentinel_file('npm_install_one'), :immediately
            end
            npm_install pkg_path+'2' do
              path pkg_path
              notifies :create, sentinel_file('npm_install_two'), :immediately
            end
            test_require('express', pkg_path)
            test_require('handlebars', pkg_path)

            # Test node_package.
            test1_path = ::File.join(new_resource.path, 'test1')
            directory test1_path
            node_package 'express' do
              path test1_path
              notifies :create, sentinel_file('test1_express_one'), :immediately
            end
            node_package 'express two' do
              package_name 'express'
              path test1_path
              notifies :create, sentinel_file('test1_express_two'), :immediately
            end
            node_package %w{gulp less} do
              path test1_path
              notifies :create, sentinel_file('test1_multi'), :immediately
            end
            node_package %w{express bower} do
              path test1_path
              notifies :create, sentinel_file('test1_multi_overlap'), :immediately
            end
            node_package 'bower' do
              path test1_path
              notifies :create, sentinel_file('test1_bower'), :immediately
            end
            node_package 'yo' do
              path test1_path
              version '1.4.5'
            end if new_resource.test_yo
            node_package 'forever' do
              path test1_path
              version '0.13.0'
            end
            test_require('express', test1_path, 'node_package_express')
            test_require('gulp', test1_path)
            test_require('less', test1_path)
            test_require('bower', test1_path)
            if new_resource.test_yo
              test_require('yo', test1_path)
            else
              file ::File.join(new_resource.path, 'no_yo')
            end
            test_require('forever', test1_path)

            # Check we don't get cross talk between paths.
            test2_path = ::File.join(new_resource.path, 'test2')
            directory test2_path
            node_package 'express' do
              path test2_path
              notifies :create, sentinel_file('test2_express'), :immediately
            end

            # Test global installs.
            node_package 'grunt-cli' do
              notifies :create, sentinel_file('grunt_one'), :immediately
            end
            node_package 'grunt-cli two' do
              package_name 'grunt-cli'
              notifies :create, sentinel_file('grunt_two'), :immediately
            end
            test_require('grunt-cli', new_resource.path)
            javascript_execute 'grunt-cli --version' do
              command lazy {
                # Check local/bin first and then just bin/.
                grunt_path = ::File.expand_path('../../local/bin/grunt', javascript)
                grunt_path = ::File.expand_path('../grunt', javascript) unless ::File.exist?(grunt_path)
                "#{grunt_path} --version > #{::File.join(new_resource.path, 'grunt_version')}"
              }
            end

          end
        end

        def sentinel_file(name)
          file ::File.join(new_resource.path, "sentinel_#{name}") do
            action :nothing
          end
        end

        private

        def test_version(javascript: new_resource.name)
          # Only queue up this resource once, the ivar is just for tracking.
          @javascript_version_test ||= file ::File.join(new_resource.path, 'javascript_version.js') do
            user 'root'
            group 'root'
            mode '644'
            content <<-EOH
var fs = require('fs');
fs.writeFileSync(process.argv[2], process.version);
EOH
          end

          javascript_execute "#{@javascript_version_test.path} #{::File.join(new_resource.path, 'version')}" do
            javascript javascript if javascript
          end
        end

        def test_require(name, cwd, path=name, javascript: new_resource.name)
          javascript_require_test = file ::File.join(cwd, 'javascript_require.js') do
            user 'root'
            group 'root'
            mode '644'
            content <<-EOH
var fs = require('fs');
try {
  var version = require(process.argv[2] + '/package.json').version;
  fs.writeFileSync(process.argv[3], version);
} catch(e) {
}
EOH
          end

          javascript_execute "#{javascript_require_test.path} #{name} #{::File.join(new_resource.path, "require_#{path}")}" do
            javascript javascript if javascript
            cwd cwd
          end
        end

      end
    end
  end
end
