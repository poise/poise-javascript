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

describe PoiseJavascript::JavascriptProviders::Dummy do
  let(:javascript_runtime) { chef_run.javascript_runtime('test') }
  step_into(:javascript_runtime)
  recipe do
    javascript_runtime 'test' do
      provider :dummy
    end
  end

  describe '#javascript_binary' do
    subject { javascript_runtime.javascript_binary }

    it { is_expected.to eq '/node' }
  end # /describe #javascript_binary

  describe '#javascript_environment' do
    subject { javascript_runtime.javascript_environment }

    it { is_expected.to eq({}) }
  end # /describe #javascript_environment

  describe '#npm_binary' do
    subject { javascript_runtime.npm_binary }

    it { is_expected.to eq '/npm' }
  end # /describe #npm_binary

  describe 'action :install' do
    # Just make sure it doesn't error.
    it { run_chef }
  end # /describe action :install

  describe 'action :uninstall' do
    recipe do
      javascript_runtime 'test' do
        action :uninstall
        provider :dummy
      end
    end

    # Just make sure it doesn't error.
    it { run_chef }
  end # /describe action :uninstall
end
