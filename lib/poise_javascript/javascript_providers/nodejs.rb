#
# Copyright 2015-2017, Noah Kantrowitz
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
        # LTS version is first so that it is what you get for version ''.
        versions: %w{8.9.4 9.7.1 9.6.1 9.5.0 9.4.0 9.3.0 9.2.1 9.1.0 9.0.0 8.8.1 8.7.0 8.6.0 8.5.0 8.4.0 8.3.0 8.2.1 8.1.4 8.0.0 7.10.1 7.9.0 7.8.0 7.7.4 7.6.0 7.5.0 7.4.0 7.3.0 7.2.1 7.1.0 7.0.0 6.13.0 6.12.3 6.11.5 6.10.3 6.9.5 6.8.1 6.7.0 6.6.0 6.5.0 6.4.0 6.3.1 6.2.2 6.1.0 6.0.0 5.12.0 5.11.1 5.10.1 5.9.1 5.8.0 5.7.1 5.6.0 5.5.0 5.4.1 5.3.0 5.2.0 5.1.1 5.0.0 4.8.7 4.7.3 4.6.2 4.5.0 4.4.7 4.3.2 4.2.6 4.1.2 4.0.0 0.12.18 0.11.16 0.10.48 0.9.12 0.8.28 0.7.12 0.6.21 0.5.10 0.4.12 0.3.8 0.2.6 0.1.104},
        machines: %w{linux-i686 linux-x86_64 linux-armv6l linux-armv7l linux-arm64 darwin-x86_64},
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

