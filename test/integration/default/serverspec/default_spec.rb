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

  describe 'npm_install' do
    assert_file('sentinel_npm_install_one')
    assert_file('sentinel_npm_install_two', false)
    assert_file('require_express') do
      its(:content) { is_expected.to eq '4.13.3' }
    end
    assert_file('require_handlebars', false)
  end

  describe 'node_package' do
    assert_file('sentinel_test1_express_one')
    assert_file('sentinel_test1_express_two', false)
    assert_file('sentinel_test1_multi')
    assert_file('sentinel_test1_multi_overlap')
    assert_file('sentinel_test1_bower', false)
    assert_file('require_node_package_express') do
      its(:content) { is_expected.to_not eq '' }
    end
    assert_file('require_gulp') do
      its(:content) { is_expected.to_not eq '' }
    end
    assert_file('require_less') do
      its(:content) { is_expected.to_not eq '' }
    end
    assert_file('require_bower') do
      its(:content) { is_expected.to_not eq '' }
    end
    assert_file('require_yo') do
      its(:content) { is_expected.to eq '1.4.5' }
    end unless File.exist?(File.join('', 'root', "javascript_test_#{javascript_name}", 'no_yo'))
    assert_file('require_forever') do
      its(:content) { is_expected.to eq '0.13.0' }
    end

    assert_file('sentinel_test2_express')

    assert_file('sentinel_grunt_one')
    assert_file('sentinel_grunt_two', false)
    assert_file('require_grunt-cli', false)
    assert_file('grunt_version') do
      its(:content) { is_expected.to start_with 'grunt-cli v' }
    end
  end
end

describe 'nodejs LTS' do
  it_should_behave_like 'a javascript_runtime_test', 'nodejs'
end

describe 'nodejs 9' do
  it_should_behave_like 'a javascript_runtime_test', 'nodejs-9', 'v9'
end

describe 'nodejs 4' do
  it_should_behave_like 'a javascript_runtime_test', 'nodejs-4', 'v4'
end

describe 'system provider', unless: File.exist?('/no_system') do
  it_should_behave_like 'a javascript_runtime_test', 'system'
end

describe 'scl provider', unless: File.exist?('/no_scl') do
  it_should_behave_like 'a javascript_runtime_test', 'scl'
end
