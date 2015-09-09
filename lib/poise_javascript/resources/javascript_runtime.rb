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

require 'chef/resource'
require 'poise'


module PoiseJavascript
  module Resources
    # (see JavascriptRuntime::Resource)
    # @since 1.0.0
    module JavascriptRuntime
      # A `javascript_runtime` resource to manage Javascript installations.
      #
      # @provides javascript_runtime
      # @action install
      # @action uninstall
      # @example
      #   javascript_runtime '2.7'
      class Resource < Chef::Resource
        include Poise(inversion: true, container: true)
        provides(:javascript_runtime)
        actions(:install, :uninstall)

        # @!attribute version
        #   Version of Javascript to install. This is generally a NodeJS version
        #   but because of io.js there are shenanigans.
        #   @return [String]
        #   @example Install any version
        #     javascript_runtime 'any' do
        #       version ''
        #     end
        attribute(:version, kind_of: String, name_attribute: true)

        # The path to the `node` binary for this Javascript installation. This is
        # an output property.
        #
        # @return [String]
        # @example
        #   execute "#{resources('javascript_runtime[nodejs]').javascript_binary} myapp.js"
        def javascript_binary
          provider_for_action(:javascript_binary).javascript_binary
        end

        # The environment variables for this Javascript installation. This is an
        # output property.
        #
        # @return [Hash<String, String>]
        # @example
        #   execute '/opt/myapp.js' do
        #     environment resources('javascript_runtime[nodejs]').javascript_environment
        #   end
        def javascript_environment
          provider_for_action(:javascript_environment).javascript_environment
        end

        # The path to the `npm` binary for this Javascript installation. This is
        # an output property. Can raise an exception if NPM is not supported for
        # this runtime.
        #
        # @return [String]
        # @example
        #   execute "#{resources('javascript_runtime[nodejs]').npm_binary} install"
        def npm_binary
          provider_for_action(:npm_binary).npm_binary
        end
      end

      # Providers can be found under lib/poise_javascript/javascript_providers/
    end
  end
end
