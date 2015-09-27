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

require 'chef/platform/provider_priority_map'

require 'poise_javascript/javascript_providers/dummy'
require 'poise_javascript/javascript_providers/iojs'
require 'poise_javascript/javascript_providers/nodejs'
require 'poise_javascript/javascript_providers/scl'
require 'poise_javascript/javascript_providers/system'


module PoiseJavascript
  # Inversion providers for the javascript_runtime resource.
  #
  # @since 1.0.0
  module JavascriptProviders
    autoload :Base, 'poise_javascript/javascript_providers/base'

    Chef::Platform::ProviderPriorityMap.instance.priority(:javascript_runtime, [
      PoiseJavascript::JavascriptProviders::IOJS,
      PoiseJavascript::JavascriptProviders::NodeJS,
      PoiseJavascript::JavascriptProviders::Scl,
      PoiseJavascript::JavascriptProviders::System,
    ])
  end
end
