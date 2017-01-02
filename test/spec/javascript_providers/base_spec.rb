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

describe PoiseJavascript::JavascriptProviders::Base do
  # Literally only here for coverage.
  step_into(:javascript_runtime)
  provider(:poise_test, parent: described_class) do
    provides(:poise_test)
  end

  describe 'install_javascript' do
    recipe do
      javascript_runtime 'test' do
        provider :poise_test
      end
    end

    it { expect { subject }.to raise_error NotImplementedError }
  end # /describe install_javascript

  describe 'uninstall_javascript' do
    recipe do
      javascript_runtime 'test' do
        action :uninstall
        provider :poise_test
      end
    end

    it { expect { subject }.to raise_error NotImplementedError }
  end # /describe uninstall_javascript

  describe '#javascript_binary' do
    recipe(subject: false) do
      javascript_runtime 'test' do
        action :nothing
        provider :poise_test
      end
    end
    subject { chef_run.javascript_runtime('test').javascript_binary }

    it { expect { subject }.to raise_error NotImplementedError }
  end # /describe #javascript_binary

  describe '#javascript_environment' do
    recipe(subject: false) do
      javascript_runtime 'test' do
        action :nothing
        provider :poise_test
      end
    end
    subject { chef_run.javascript_runtime('test').javascript_environment }

    it { is_expected.to eq({}) }
  end # /describe #javascript_environment

  describe '#npm_binary' do
    provider(:poise_test2, parent: described_class) do
      provides(:poise_test2)

      def javascript_binary
        '/usr/bin/node'
      end
    end
    recipe(subject: false) do
      javascript_runtime 'test' do
        action :nothing
        provider :poise_test2
      end
    end
    subject { chef_run.javascript_runtime('test').npm_binary }

    it { is_expected.to eq '/usr/bin/npm' }
  end # /describe #npm_binary
end
