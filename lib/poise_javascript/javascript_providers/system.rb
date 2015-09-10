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
    class System < Base
      include PoiseLanguages::System::Mixin
      provides(:system)
      packages('nodejs', {
        debian: {default: %w{nodejs}},
        ubuntu: {default: %w{nodejs}},
        # Empty arrays because no package in the base OS.
        redhat: {default: %w{}},
        centos: {default: %w{}},
        fedora: {default: %w{nodejs}},
        amazon: {default: %w{}},
      })

      def self.provides_auto?(node, resource)
        # Don't auto on platforms I know have no system package by default. Kind
        # of pointless since the nodejs provider will hit on these platforms
        # anyway so this shouldn't ever happen.
        super && !node.platform_family?('rhel') && !node.platform?('amazon')
      end

      def javascript_binary
        # Debian and Ubuntu after 12.04 changed the binary name ಠ_ಠ.
        binary_name = node.value_for_platform(debian: {default: 'nodejs'}, ubuntu: {'12.04' => 'node', default: 'nodejs'}, default: 'node')
        ::File.join('', 'usr', 'bin', binary_name)
      end

      private

      def install_javascript
        install_system_packages
        package %w{npm nodejs-legacy} if node.platform_family?('debian')
      end

      def uninstall_javascript
        uninstall_system_packages
        package(%w{npm nodejs-legacy}) { action :purge } if node.platform_family?('debian')
      end

      def system_package_candidates(version)
        # Boring :-(.
        %w{nodejs nodejs-legacy node}
      end

    end
  end
end
