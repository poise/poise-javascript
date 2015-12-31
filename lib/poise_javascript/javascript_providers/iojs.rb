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
    class IOJS < Base
      provides(:iojs)
      include PoiseLanguages::Static(
        versions: %w{3.3.1 3.2.0 3.1.0 3.0.0 2.5.0 2.4.0 2.3.4 2.2.1 2.1.0 2.0.2 1.8.4 1.7.1 1.6.4 1.5.1 1.4.3 1.3.0 1.2.0 1.1.0 1.0.4},
        machines: %w{linux-i686 linux-x86_64 darwin-x86_64},
        url: 'https://iojs.org/dist/v%{version}/iojs-v%{version}-%{kernel}-%{machine}.tar.gz',
      )

      def self.provides_auto?(node, resource)
        # Also work if we have a version starting with 1. 2. or 3. since that has
        # to be io.js and no other mechanism supports that.
        super || (resource.version.to_s =~ /^[123](\.|$)/ && static_machines.include?(static_machine_label(node)))
      end

      MACHINE_LABELS = {'i386' => 'x86', 'i686' => 'x86', 'x86_64' => 'x64'}

      def static_url_variables
        machine = node['kernel']['machine']
        super.merge(machine: MACHINE_LABELS[machine] || machine)
      end

      def javascript_binary
        ::File.join(static_folder, 'bin', 'iojs')
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

