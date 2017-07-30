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

describe PoiseJavascript::JavascriptProviders::System do
  let(:javascript_version) { '' }
  let(:chefspec_options) { {platform: 'ubuntu', version: '14.04'} }
  let(:default_attributes) { {poise_javascript_version: javascript_version} }
  let(:javascript_runtime) { chef_run.javascript_runtime('test') }
  let(:system_package_candidates) { javascript_runtime.provider_for_action(:install).send(:system_package_candidates, javascript_version) }
  step_into(:javascript_runtime)
  recipe do
    javascript_runtime 'test' do
      provider :system
      version node['poise_javascript_version']
    end
  end

  shared_examples_for 'system provider' do |candidates, pkg, bin|
    it { expect(javascript_runtime.provider_for_action(:install)).to be_a described_class }
    it { expect(javascript_runtime.javascript_binary).to eq File.join('', 'usr', 'bin', bin) }
    it { expect(system_package_candidates).to eq candidates }
    it { is_expected.to install_poise_languages_system(pkg) }
    it do
      expect_any_instance_of(described_class).to receive(:install_system_packages)
      run_chef
    end
  end

  context 'on Ubuntu' do
    let(:chefspec_options) { {platform: 'ubuntu', version: '16.04'} }
    it_behaves_like 'system provider', %w{nodejs nodejs-legacy node}, 'nodejs', 'nodejs'
  end # /context on Ubuntu

  context 'on Gentoo' do
    let(:chefspec_options) { {platform: 'gentoo', version: '4.9.6-gentoo-r1' } }
    it_behaves_like 'system provider', %w{nodejs nodejs-legacy node}, 'nodejs', 'node'
  end # /context on Gentoo

  context 'on CentOS' do
    let(:chefspec_options) { {platform: 'centos', version: '7.3.1611'} }
    it { expect { subject }.to raise_error PoiseLanguages::Error }
  end # /context on CentOS

  context 'action :uninstall' do
    recipe do
      javascript_runtime 'test' do
        action :uninstall
        provider :system
      end
    end

    it do
      expect_any_instance_of(described_class).to receive(:uninstall_system_packages)
      run_chef
    end
    it { expect(javascript_runtime.provider_for_action(:uninstall)).to be_a described_class }
  end # /context action :uninstall
end
