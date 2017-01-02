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

describe PoiseJavascript::JavascriptProviders::IOJS do
  let(:javascript_version) { nil }
  let(:chefspec_options) { {platform: 'ubuntu', version: '14.04'} }
  let(:default_attributes) { {poise_javascript_version: javascript_version} }
  let(:javascript_runtime) { chef_run.javascript_runtime('test') }
  step_into(:javascript_runtime)
  recipe do
    javascript_runtime 'test' do
      version node['poise_javascript_version']
    end
  end

  shared_examples_for 'iojs provider' do |base, url|
    it { expect(javascript_runtime.provider_for_action(:install)).to be_a described_class }
    it { is_expected.to install_poise_languages_static(File.join('', 'opt', base)).with(source: url) }
    it { expect(javascript_runtime.javascript_binary).to eq File.join('', 'opt', base, 'bin', 'iojs') }
  end

  context 'with version iojs' do
    let(:javascript_version) { 'iojs' }
    it_behaves_like 'iojs provider', 'iojs-3.3.1', 'https://iojs.org/dist/v3.3.1/iojs-v3.3.1-linux-x64.tar.gz'
  end # /context with version iojs

  context 'with version iojs-2' do
    let(:javascript_version) { 'iojs-2' }
    it_behaves_like 'iojs provider', 'iojs-2.5.0', 'https://iojs.org/dist/v2.5.0/iojs-v2.5.0-linux-x64.tar.gz'
  end # /context with version iojs-2

  context 'with version iojs-2.4.0' do
    let(:javascript_version) { 'iojs-2.4.0' }
    it_behaves_like 'iojs provider', 'iojs-2.4.0', 'https://iojs.org/dist/v2.4.0/iojs-v2.4.0-linux-x64.tar.gz'
  end # /context with version iojs-2.4.0

  context 'with version 3' do
    let(:javascript_version) { '3' }
    it_behaves_like 'iojs provider', 'iojs-3.3.1', 'https://iojs.org/dist/v3.3.1/iojs-v3.3.1-linux-x64.tar.gz'
  end # /context with version 3

  context 'with 32-bit OS' do
    recipe do
      node.automatic['kernel']['machine'] = 'i686'
      javascript_runtime 'test' do
        version 'iojs'
      end
    end
    it_behaves_like 'iojs provider', 'iojs-3.3.1', 'https://iojs.org/dist/v3.3.1/iojs-v3.3.1-linux-x86.tar.gz'
  end # /context with 32-bit OS

  context 'action :uninstall' do
    recipe do
      javascript_runtime 'test' do
        version 'iojs'
        action :uninstall
      end
    end

    it { is_expected.to uninstall_poise_languages_static('/opt/iojs-3.3.1') }
  end # /context action :uninstall
end
