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

require 'serverspec'
set :backend, :exec

# Set up the shared example for javascript_runtime_test.
RSpec.shared_examples 'a javascript_runtime_test' do |javascript_name, version=nil|
  let(:javascript_name) { javascript_name }
  let(:javascript_path) { File.join('', 'root', "javascript_test_#{javascript_name}") }
  # Helper for all the file checks.
  def self.assert_file(rel_path, should_exist=true, &block)
    describe rel_path do
      subject { file(File.join(javascript_path, rel_path)) }
      # Do nothing for nil.
      if should_exist == true
        it { is_expected.to be_a_file }
      elsif should_exist == false
        it { is_expected.to_not exist }
      end
      instance_eval(&block) if block
    end
  end

  describe 'javascript_runtime' do
    assert_file('version') do
      its(:content) { is_expected.to start_with version } if version
    end
  end
end

describe 'default' do
  it_should_behave_like 'a javascript_runtime_test', 'default', 'v0.12'
end

describe 'nodejs 0.12' do
  it_should_behave_like 'a javascript_runtime_test', '0.12', 'v0.12'
end

describe 'iojs 3' do
  it_should_behave_like 'a javascript_runtime_test', '3', 'v3'
end

describe 'nodejs' do
  it_should_behave_like 'a javascript_runtime_test', 'nodejs'
end

describe 'node 0.10' do
  it_should_behave_like 'a javascript_runtime_test', 'nodejs-0.10', 'v0.10'
end

describe 'iojs' do
  it_should_behave_like 'a javascript_runtime_test', 'iojs'
end

describe 'system provider', unless: File.exist?('/no_system') do
  it_should_behave_like 'a javascript_runtime_test', 'system'
end

describe 'scl provider', unless: File.exist?('/no_scl') do
  it_should_behave_like 'a javascript_runtime_test', 'scl'
end
