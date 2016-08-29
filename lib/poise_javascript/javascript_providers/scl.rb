#
# Copyright 2015-2016, Noah Kantrowitz
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
require 'poise_languages'

require 'poise_javascript/error'
require 'poise_javascript/javascript_providers/base'


module PoiseJavascript
  module JavascriptProviders
    class Scl < Base
      include PoiseLanguages::Scl::Mixin
      provides(:scl)
      scl_package('4.4.2', 'rh-nodejs4', 'rh-nodejs4-nodejs-devel', '>= 7.0')
      scl_package('0.10.35', 'nodejs010', 'nodejs010-nodejs-devel')

      def javascript_binary
        ::File.join(scl_folder, 'root', 'usr', 'bin', 'node')
      end

      def javascript_environment
        scl_environment
      end

      private

      def install_javascript
        install_scl_package
      end

      def uninstall_javascript
        uninstall_scl_package
      end

    end
  end
end

