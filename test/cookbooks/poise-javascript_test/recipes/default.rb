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

require 'poise_javascript/resources/javascript_runtime_test'

# Install lsb-release because Debian 6 doesn't by default and serverspec requires it
package 'lsb-release' if platform?('debian') && node['platform_version'].start_with?('6')

# javascript_runtime_test 'default' do
#   version ''
# end

# javascript_runtime_test '0.12'

# javascript_runtime_test '3'

javascript_runtime_test 'nodejs'

javascript_runtime_test 'nodejs-0.10' do
  test_yo false
end

javascript_runtime_test 'iojs'

if platform_family?('rhel')
  javascript_runtime_test 'scl' do
    version ''
    runtime_provider :scl
  end
else
  file '/no_scl'
end

# npm in 12.04 seems to be busted.
if !platform_family?('rhel') && !(platform?('ubuntu') && node['platform_version'] == '12.04')
  javascript_runtime_test 'system' do
    version ''
    runtime_provider :system
    test_yo false
  end
else
  file '/no_system'
end
