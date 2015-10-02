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
require 'poise_languages'

require 'poise_javascript/error'
require 'poise_javascript/javascript_providers/base'


module PoiseJavascript
  module JavascriptProviders
    class Scl < Base
      include PoiseLanguages::Scl::Mixin
      provides(:scl)
      scl_package('0.10.35', 'nodejs010', 'nodejs010-nodejs-devel', {
        ['redhat', 'centos'] => {
          '~> 7.0' => 'https://www.softwarecollections.org/en/scls/rhscl/nodejs010/epel-7-x86_64/download/rhscl-nodejs010-epel-7-x86_64.noarch.rpm',
          '~> 6.0' => 'https://www.softwarecollections.org/en/scls/rhscl/nodejs010/epel-6-x86_64/download/rhscl-nodejs010-epel-6-x86_64.noarch.rpm',
        },
      })

      V8_SCL_URLS = {
        ['redhat', 'centos'] => {
          '~> 7.0' => 'https://www.softwarecollections.org/en/scls/rhscl/v8314/epel-7-x86_64/download/rhscl-v8314-epel-7-x86_64.noarch.rpm',
          '~> 6.0' => 'https://www.softwarecollections.org/en/scls/rhscl/v8314/epel-6-x86_64/download/rhscl-v8314-epel-6-x86_64.noarch.rpm',
        },
      }

      def javascript_binary
        ::File.join(scl_folder, 'root', 'usr', 'bin', 'node')
      end

      def javascript_environment
        scl_environment
      end

      private

      def install_javascript
        install_v8_scl_package
        install_scl_package
      end

      def uninstall_javascript
        uninstall_scl_package
        uninstall_v8_scl_package
      end

      def install_v8_scl_package
        poise_languages_scl 'v8314' do
          parent new_resource
          url node.value_for_platform(V8_SCL_URLS)
        end
      end

      def uninstall_v8_scl_package
        install_v8_scl_package.tap do |r|
          r.action(:uninstall)
        end
      end

    end
  end
end

