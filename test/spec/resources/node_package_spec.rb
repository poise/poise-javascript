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
          response_file_variables({})
        end
      end

      it { expect { subject }.to raise_error NoMethodError }
    end # /describe #response_file_variables
  end # /describe PoiseJavascript::Resources::NodePackage::Resource

  describe PoiseJavascript::Resources::NodePackage::Provider do
    let(:new_resource) { double('new_resource', npm_binary: '/npm') }
    let(:test_provider) { described_class.new(new_resource, nil) }

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
