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

require 'poise_javascript/resources/javascript_runtime_test'

# Install lsb-release because Debian 6 doesn't by default and serverspec requires it
package 'lsb-release' if platform?('debian') && node['platform_version'].start_with?('6')

javascript_runtime_test 'nodejs'

javascript_runtime_test 'nodejs-9'

javascript_runtime_test 'nodejs-4'

if platform_family?('rhel') && !node['platform_version'].start_with?('6')
  javascript_runtime_test 'scl' do
    version ''
    runtime_provider :scl
    test_yo false
  end
else
  file '/no_scl'
end

# npm in 12.04 and 14.04 is too old to test.
if !platform_family?('rhel') && !(platform?('ubuntu') && %w{12.04 14.04}.include?(node['platform_version']))
  javascript_runtime_test 'system' do
    version ''
    runtime_provider :system
    test_yo false
  end
else
  file '/no_system'
end
