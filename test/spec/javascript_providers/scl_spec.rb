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

require 'spec_helper'

describe PoiseJavascript::JavascriptProviders::Scl do
  let(:javascript_version) { '' }
  let(:chefspec_options) { {platform: 'centos', version: '7.3.1611'} }
  let(:default_attributes) { {poise_javascript_version: javascript_version} }
  let(:javascript_runtime) { chef_run.javascript_runtime('test') }
  step_into(:javascript_runtime)
  recipe do
    javascript_runtime 'test' do
      provider :scl
      version node['poise_javascript_version']
    end
  end

  shared_examples_for 'scl provider' do |pkg|
    it { expect(javascript_runtime.provider_for_action(:install)).to be_a described_class }
    it { expect(javascript_runtime.javascript_binary).to eq File.join('', 'opt', 'rh', pkg, 'root', 'usr', 'bin', 'node') }
    it { is_expected.to install_poise_languages_scl(pkg) }
    it do
      expect_any_instance_of(described_class).to receive(:install_scl_package)
      run_chef
    end
    it do
      expect_any_instance_of(described_class).to receive(:scl_environment)
      javascript_runtime.javascript_environment
    end
  end

  context 'with version ""' do
    let(:javascript_version) { '' }
    it_behaves_like 'scl provider', 'rh-nodejs4'
  end # /context with version ""

  context 'with version "0.10"' do
    let(:javascript_version) { '0.10' }
    it_behaves_like 'scl provider', 'nodejs010'
  end # /context with version "0.10"

  context 'with version "4"' do
    let(:javascript_version) { '4' }
    it_behaves_like 'scl provider', 'rh-nodejs4'
  end # /context with version "4"


  context 'with version "" on CentOS 6' do
    let(:chefspec_options) { {platform: 'centos', version: '6.9'} }
    let(:javascript_version) { '' }
    it_behaves_like 'scl provider', 'nodejs010'
  end # /context with version "" on CentOS 6

  context 'action :uninstall' do
    recipe do
      javascript_runtime 'test' do
        action :uninstall
        provider :scl
        version node['poise_javascript_version']
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:uninstall_scl_package)
      run_chef
    end
    it { expect(javascript_runtime.provider_for_action(:uninstall)).to be_a described_class }
  end # /context action :uninstall
end
