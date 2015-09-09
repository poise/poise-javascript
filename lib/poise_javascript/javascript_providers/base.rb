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
require 'poise'


module PoiseJavascript
  module JavascriptProviders
    class Base < Chef::Provider
      include Poise(inversion: :javascript_runtime)

      # Set default inversion options.
      #
      # @api private
      def self.default_inversion_options(node, new_resource)
        super.merge({
          version: new_resource.version,
        })
      end

      # The `install` action for the `javascript_runtime` resource.
      #
      # @return [void]
      def action_install
        notifying_block do
          install_javascript
        end
      end

      # The `uninstall` action for the `javascript_runtime` resource.
      #
      # @abstract
      # @return [void]
      def action_uninstall
        notifying_block do
          uninstall_javascript
        end
      end

      # The path to the `javascript` binary. This is an output property.
      #
      # @abstract
      # @return [String]
      def javascript_binary
        raise NotImplementedError
      end

      # The environment variables for this Javascript. This is an output property.
      #
      # @return [Hash<String, String>]
      def javascript_environment
        {}
      end

      # The path to the `npm` binary. This is an output property.
      #
      # @abstract
      # @return [String]
      def npm_binary
        ::File.expand_path(::File.join('..', 'npm'), javascript_binary)
      end

      private

      # Install the Javascript runtime. Must be implemented by subclass.
      #
      # @abstract
      # @return [void]
      def install_javascript
        raise NotImplementedError
      end

      # Uninstall the Javascript runtime. Must be implemented by subclass.
      #
      # @abstract
      # @return [void]
      def uninstall_javascript
        raise NotImplementedError
      end

    end
  end
end
