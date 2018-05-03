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

describe PoiseJavascript::Resources::JavascriptExecute do
  describe PoiseJavascript::Resources::JavascriptExecute::Resource do
    recipe do
      javascript_execute 'myapp.js'
    end

    it { is_expected.to run_javascript_execute('myapp.js') }
  end # /describe PoiseJavascript::Resources::JavascriptExecute::Resource

  describe PoiseJavascript::Resources::JavascriptExecute::Provider do
    let(:command) { 'myapp.js' }
    let(:environment) { nil }
    let(:javascript) { '/node' }
    let(:parent_javascript) { nil }
    let(:new_resource) do
      double('new_resource',
        name: 'test',
        cookbook_name: 'test',
        command: command,
        environment: environment,
        javascript: javascript,
        parent_javascript: parent_javascript,
      )
    end
    subject { described_class.new(new_resource, nil) }

    context 'string command' do
      its(:command) { is_expected.to eq '/node myapp.js' }
      its(:environment) { is_expected.to be_nil }
    end # /context string command

    context 'array command' do
      let(:command) { %w{myapp.js} }
      its(:command) { is_expected.to eq %w{/node myapp.js} }
      its(:environment) { is_expected.to be_nil }
    end # /context array command

    context 'with a parent' do
      let(:parent_javascript) { double('parent_javascript', javascript_environment: {'PATH' => '/bin'}) }
      its(:command) { is_expected.to eq '/node myapp.js' }
      its(:environment) { is_expected.to eq({'PATH' => '/bin'}) }
    end # /context with a parent

    context 'with a parent and existing environment' do
      let(:environment) { {'MAN_PATH' => '/man'} }
      let(:parent_javascript) { double('parent_javascript', javascript_environment: {'PATH' => '/bin'}) }
      its(:command) { is_expected.to eq '/node myapp.js' }
      its(:environment) { is_expected.to eq({'PATH' => '/bin', 'MAN_PATH' => '/man'}) }
    end # /context with a parent and existing environment
  end # /describe PoiseJavascript::Resources::JavascriptExecute::Provider
end
