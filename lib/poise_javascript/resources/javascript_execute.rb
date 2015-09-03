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

require 'chef/mixin/which'
require 'chef/provider/execute'
require 'chef/resource/execute'
require 'poise'

require 'poise_javascript/javascript_command_mixin'


module PoiseJavascript
  module Resources
    # (see JavascriptExecute::Resource)
    # @since 1.0.0
    module JavascriptExecute
      # A `javascript_execute` resource to run Javascript scripts and commands.
      #
      # @provides javascript_execute
      # @action run
      # @example
      #   javascript_execute 'myapp.js' do
      #     user 'myuser'
      #   end
      class Resource < Chef::Resource::Execute
        include PoiseJavascript::JavascriptCommandMixin
        provides(:javascript_execute)
        actions(:run)
      end

      # The default provider for `javascript_execute`.
      #
      # @see Resource
      # @provides javascript_execute
      class Provider < Chef::Provider::Execute
        include Chef::Mixin::Which
        provides(:javascript_execute)

        private

        # Command to pass to shell_out.
        #
        # @return [String, Array<String>]
        def command
          if new_resource.command.is_a?(Array)
            [new_resource.javascript] + new_resource.command
          else
            "#{new_resource.javascript} #{new_resource.command}"
          end
        end

        # Environment variables to pass to shell_out.
        #
        # @return [Hash]
        def environment
          if new_resource.parent_javascript
            environment = new_resource.parent_javascript.javascript_environment
            if new_resource.environment
              environment = environment.merge(new_resource.environment)
            end
            environment
          else
            new_resource.environment
          end
        end

      end
    end
  end
end
