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
require 'poise_languages/static'

require 'poise_javascript/error'
require 'poise_javascript/javascript_providers/base'


module PoiseJavascript
  module JavascriptProviders
    class NodeJS < Base
      provides(:nodejs)
      include PoiseLanguages::Static(
        versions: %w{5.4.1 5.3.0 5.2.0 5.1.1 5.0.0 4.2.4 4.1.1 4.0.0 0.12.7 0.11.16 0.10.40 0.9.12 0.8.28 0.7.12 0.6.21 0.5.10},
        machines: %w{linux-i686 linux-x86_64 darwin-x86_64},
        url: 'https://nodejs.org/dist/v%{version}/node-v%{version}-%{kernel}-%{machine}.tar.gz',
      )

      def self.provides_auto?(node, resource)
        # Also work if we have a blank or numeric-y version. This should make
        # it the default provider on supported platforms.
        super || (resource.version.to_s =~ /^(\d|$)/ && static_machines.include?(static_machine_label(node)))
      end

      MACHINE_LABELS = {'i386' => 'x86', 'i686' => 'x86', 'x86_64' => 'x64'}

      def static_url_variables
        machine = node['kernel']['machine']
        super.merge(machine: MACHINE_LABELS[machine] || machine)
      end

      def javascript_binary
        ::File.join(static_folder, 'bin', 'node')
      end

      private

      def install_javascript
        install_static
      end

      def uninstall_javascript
        uninstall_static
      end

    end
  end
end

