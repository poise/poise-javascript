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

describe PoiseJavascript::Resources::NodePackage do
  describe PoiseJavascript::Resources::NodePackage::Resource do
    describe 'action :install' do
      recipe do
        node_package 'express' do
          version '1.2.3'
        end
      end

      it { is_expected.to install_node_package('express').with(version: '1.2.3') }
    end # /describe action :install

    describe 'action :upgrade' do
      recipe do
        node_package 'express' do
          action :upgrade
          version '1.2.3'
        end
      end

      it { is_expected.to upgrade_node_package('express').with(version: '1.2.3') }
    end # /describe action :upgrade

    describe 'action :remove' do
      recipe do
        node_package 'express' do
          action :remove
          version '1.2.3'
        end
      end

      it { is_expected.to remove_node_package('express').with(version: '1.2.3') }
    end # /describe action :remove

    describe 'action :purge' do
      recipe do
        node_package 'express' do
          action :purge
          version '1.2.3'
        end
      end

      it { expect { subject }.to raise_error Chef::Exceptions::ValidationFailed }
    end # /describe action :purge

    describe 'action :reconfig' do
      recipe do
        node_package 'express' do
          action :reconfig
          version '1.2.3'
        end
      end

      it { expect { subject }.to raise_error Chef::Exceptions::ValidationFailed }
    end # /describe action :reconfig

    describe '#response_file' do
      recipe do
        node_package 'express' do
          response_file '/response'
        end
      end

      it { expect { subject }.to raise_error NoMethodError }
    end # /describe #response_file

    describe '#response_file_variables' do
      recipe do
        node_package 'express' do
          response_file_variables({a: 1})
        end
      end

      it { expect { subject }.to raise_error NoMethodError }
    end # /describe #response_file_variables
  end # /describe PoiseJavascript::Resources::NodePackage::Resource

  describe PoiseJavascript::Resources::NodePackage::Provider do
    let(:new_resource) { double('new_resource', name: 'test', cookbook_name: 'test', path: nil, javascript: '/node', npm_binary: '/npm', user: nil, group: nil) }
    let(:test_provider) { described_class.new(new_resource, chef_run.run_context) }

    def stub_javascript_shell_out(cmd, ret, **options)
      default_options = {cwd: nil, user: nil, group: nil, environment: {'PATH' => "/:#{ENV['PATH']}"}}
      allow(test_provider).to receive(:javascript_shell_out!).with(cmd, default_options.merge(options)).and_return(double(stdout: ret))
    end

    describe '#load_current_resource' do
      let(:new_resource) do
        PoiseJavascript::Resources::NodePackage::Resource.new('mypkg', nil)
      end
      subject { test_provider.load_current_resource }

      it do
        expect(test_provider).to receive(:check_package_versions)
        is_expected.to be_a PoiseJavascript::Resources::NodePackage::Resource
      end
    end # /describe #load_current_resource

    describe '#check_package_versions' do
      let(:package_name) { }
      let(:current_resource) { PoiseJavascript::Resources::NodePackage::Resource.new(package_name, nil) }
      let(:npm_version) { '2.12.1' }
      let(:npm_list_out) { <<-EOH }
{
  "dependencies": {
    "bower": {
      "version": "1.3.12",
      "from": "bower@*",
      "resolved": "https://registry.npmjs.org/bower/-/bower-1.3.12.tgz"
    },
    "coffeelint": {
      "version": "1.9.3",
      "from": "coffeelint@*",
      "resolved": "https://registry.npmjs.org/coffeelint/-/coffeelint-1.9.3.tgz"
    },
    "ember-cli": {
      "version": "0.2.7",
      "from": "ember-cli@*",
      "resolved": "https://registry.npmjs.org/ember-cli/-/ember-cli-0.2.7.tgz"
    },
    "gulp": {
      "version": "3.8.11",
      "from": "gulp@*",
      "resolved": "https://registry.npmjs.org/gulp/-/gulp-3.8.11.tgz"
    },
    "npm": {
      "version": "2.12.1",
      "from": "../../../../../../../private/tmp/node20150704-67289-jytzoh/node-v0.12.6/npm_install",
      "resolved": "file:../../../../../../../private/tmp/node20150704-67289-jytzoh/node-v0.12.6/npm_install"
    },
    "phantomjs": {
      "version": "1.9.16",
      "from": "phantomjs@*",
      "resolved": "https://registry.npmjs.org/phantomjs/-/phantomjs-1.9.16.tgz"
    }
  }
}
EOH
      subject do
        test_provider.check_package_versions(current_resource)
        {version: current_resource.version, candidate_version: test_provider.candidate_version}
      end
      before do
        allow(test_provider).to receive(:npm_version).and_return(Gem::Version.new(npm_version))
      end

      context 'with a single package' do
        let(:package_name) { 'express' }

        before do
          stub_javascript_shell_out(%w{/npm list --json --global --depth 0}, npm_list_out)
          stub_javascript_shell_out(%w{/npm show --json --global express}, '{"version": "1.2.3"}')
        end

        its([:version]) { is_expected.to be_nil }
        its([:candidate_version]) { is_expected.to eq '1.2.3' }
      end # /context with a single package

      context 'with an already installed package' do
        let(:package_name) { 'bower' }

        before do
          stub_javascript_shell_out(%w{/npm list --json --global --depth 0}, npm_list_out)
          stub_javascript_shell_out(%w{/npm outdated --json --global}, <<-EOH, returns: [0, 1])
{
  "bower": {
    "current": "1.3.12",
    "wanted": "1.5.2",
    "latest": "1.5.2",
    "location": "/usr/local/lib/node_modules/bower"
  }
}
EOH
        end

        its([:version]) { is_expected.to eq '1.3.12' }
        its([:candidate_version]) { is_expected.to eq '1.5.2' }
      end # /context with an already installed package

      context 'with multiple packages' do
        let(:package_name) { %w{express bower} }

        before do
          stub_javascript_shell_out(%w{/npm list --json --global --depth 0}, npm_list_out)
          stub_javascript_shell_out(%w{/npm outdated --json --global}, <<-EOH, returns: [0, 1])
{
  "bower": {
    "current": "1.3.12",
    "wanted": "1.5.2",
    "latest": "1.5.2",
    "location": "/usr/local/lib/node_modules/bower"
  }
}
EOH
          stub_javascript_shell_out(%w{/npm show --json --global express}, '{"version": "1.2.3"}')
        end

        its([:version]) { is_expected.to eq [nil, '1.3.12'] }
        its([:candidate_version]) { is_expected.to eq %w{1.2.3 1.5.2} }
      end # /context with multiple packages

      context 'with empty outdated' do
        let(:package_name) { 'bower' }

        before do
          stub_javascript_shell_out(%w{/npm list --json --global --depth 0}, npm_list_out)
          stub_javascript_shell_out(%w{/npm outdated --json --global}, '', returns: [0, 1])
        end

        its([:version]) { is_expected.to eq '1.3.12' }
        its([:candidate_version]) { is_expected.to eq '1.3.12' }
      end # /context with empty outdated
    end # /describe #check_package_versions

    describe '#install_package' do
      let(:unsafe_perm) { true }
      let(:source) { nil }
      before do
        allow(new_resource).to receive(:unsafe_perm).and_return(unsafe_perm)
        allow(new_resource).to receive(:source).and_return(source)
      end

      context 'with a package' do
        it do
          stub_javascript_shell_out(%w{/npm install --json --global --unsafe-perm true express@1.2.3}, '')
          test_provider.install_package('express', '1.2.3')
        end
      end # /context with a package

      context 'with mutliple packages' do
        it do
          stub_javascript_shell_out(%w{/npm install --json --global --unsafe-perm true express@1.2.3 bower@1.3.12}, '')
          test_provider.install_package(%w{express bower}, %w{1.2.3 1.3.12})
        end
      end # /context with mutliple packages

      context 'with a source' do
        let(:source) { 'git@example.com'}
        it do
          stub_javascript_shell_out(%w{/npm install --json --global --unsafe-perm true git@example.com}, '')
          test_provider.install_package('express', '1.2.3')
        end
      end # /context with a source

      context 'with unsafe_perm false' do
      let(:unsafe_perm) { false }
        it do
          stub_javascript_shell_out(%w{/npm install --json --global --unsafe-perm false express@1.2.3}, '')
          test_provider.install_package('express', '1.2.3')
        end
      end # /context with unsafe_perm false

      context 'with unsafe_perm nil' do
      let(:unsafe_perm) { nil }
        it do
          stub_javascript_shell_out(%w{/npm install --json --global express@1.2.3}, '')
          test_provider.install_package('express', '1.2.3')
        end
      end # /context with unsafe_perm nil
    end # /describe #install_package

    describe '#remove_package' do
      # Side effectsssss.
      it do
        stub_javascript_shell_out(%w{/npm uninstall --json --global express}, 'something that is not JSON')
        test_provider.remove_package('express', '1.2.3')
      end
    end # /describe #remove_package

    describe '#npm_version' do
      let(:npm_version_output) { '' }
      subject { test_provider.send(:npm_version).to_s }
      before do
        allow(test_provider).to receive(:javascript_shell_out!).with(%w{/npm version}).and_return(double('shell_out', stdout: npm_version_output))
      end

      context 'with empty output' do
        it { expect { subject }.to raise_error PoiseJavascript::Error }
      end # /context with empty output

      context 'with expected output' do
        let(:npm_version_output) { <<-EOH }
{ npm: '2.12.1',
  http_parser: '2.3',
  modules: '14',
  node: '0.12.6',
  openssl: '1.0.1o',
  uv: '1.6.1',
  v8: '3.28.71.19',
  zlib: '1.2.8' }
EOH
        it { is_expected.to eq '2.12.1' }
      end # /context with expected output
    end # /describe #npm_version

    describe '#npm_version?' do
      let(:version_req) { '>= 1.0.0'}
      subject { test_provider.send(:npm_version?, version_req) }
      before do
        allow(test_provider).to receive(:npm_version).and_return(Gem::Version.new('1.0.0'))
      end

      it { is_expected.to be true }
    end # /describe #npm_version?
  end # /describe PoiseJavascript::Resources::NodePackage::Provider
end
