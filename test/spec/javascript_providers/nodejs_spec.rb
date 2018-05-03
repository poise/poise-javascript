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

describe PoiseJavascript::JavascriptProviders::NodeJS do
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

  shared_examples_for 'nodejs provider' do |base, url|
    it { expect(javascript_runtime.provider_for_action(:install)).to be_a described_class }
    it { is_expected.to install_poise_languages_static(File.join('', 'opt', base)).with(source: url) }
    it { expect(javascript_runtime.javascript_binary).to eq File.join('', 'opt', base, 'bin', 'node') }
  end

  context 'with version ""' do
    let(:javascript_version) { '' }
    it_behaves_like 'nodejs provider', 'nodejs-8.11.1', 'https://nodejs.org/dist/v8.11.1/node-v8.11.1-linux-x64.tar.gz'
  end # /context with version ""

  context 'with version nodejs' do
    let(:javascript_version) { 'nodejs' }
    it_behaves_like 'nodejs provider', 'nodejs-8.11.1', 'https://nodejs.org/dist/v8.11.1/node-v8.11.1-linux-x64.tar.gz'
  end # /context with version nodejs

  context 'with version nodejs-0.10' do
    let(:javascript_version) { 'nodejs-0.10' }
    it_behaves_like 'nodejs provider', 'nodejs-0.10.48', 'https://nodejs.org/dist/v0.10.48/node-v0.10.48-linux-x64.tar.gz'
  end # /context with version nodejs-0.10

  context 'with version nodejs-0.10.30' do
    let(:javascript_version) { 'nodejs-0.10.30' }
    it_behaves_like 'nodejs provider', 'nodejs-0.10.30', 'https://nodejs.org/dist/v0.10.30/node-v0.10.30-linux-x64.tar.gz'
  end # /context with version nodejs-0.10.30

  context 'with version 0.12' do
    let(:javascript_version) { '0.12' }
    it_behaves_like 'nodejs provider', 'nodejs-0.12.18', 'https://nodejs.org/dist/v0.12.18/node-v0.12.18-linux-x64.tar.gz'
  end # /context with version 0.12

  context 'with 32-bit OS' do
    recipe do
      node.automatic['kernel']['machine'] = 'i686'
      javascript_runtime 'test' do
        version ''
      end
    end
    it_behaves_like 'nodejs provider', 'nodejs-8.11.1', 'https://nodejs.org/dist/v8.11.1/node-v8.11.1-linux-x86.tar.gz'
  end # /context with 32-bit OS

  context 'action :uninstall' do
    recipe do
      javascript_runtime 'test' do
        version ''
        action :uninstall
      end
    end

    it { is_expected.to uninstall_poise_languages_static('/opt/nodejs-8.11.1') }
  end # /context action :uninstall

  describe 'release checker' do
    let(:class_versions) { described_class.static_versions }
    let(:node_versions) { Chef::JSONCompat.parse(Chef::HTTP::Simple.new('https://nodejs.org/').get('/dist/index.json')) }
    let(:current_lts) { node_versions.find {|ver| ver['lts'] }['version'][/v(.*)/, 1] }
    let(:desired_versions) do
      versions = node_versions.map {|ver| ver['version'][/v(.*)/, 1] }
      clean_versions = versions.each_with_object([]) do |ver, acc|
        minor = ver[/^(.*?\.)\d+$/, 1]
        unless acc.any? {|v| v.start_with?(minor) }
          acc << ver
        end
      end
      clean_versions.delete(current_lts)
      [current_lts] + clean_versions
    end
    it { expect(desired_versions.join("\n")).to eq(class_versions.join("\n")), "NodeJS versions out of date:\n%w{#{desired_versions.join(' ')}}" }
  end # /describe release checker
end
