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

describe PoiseJavascript::JavascriptCommandMixin do
  describe PoiseJavascript::JavascriptCommandMixin::Resource do
    resource(:poise_test) do
      include described_class
    end
    provider(:poise_test)
    subject { resource(:poise_test).new('test', nil) }

    it { is_expected.to respond_to :parent_javascript }
    it { is_expected.to respond_to :javascript }
    it { expect(subject.respond_to?(:javascript_from_parent, true)).to be true }

    describe '#npm_binary' do
      context 'with a parent' do
        recipe do
          javascript_runtime 'test' do
            provider :dummy
          end
          poise_test 'test'
        end

        it { is_expected.to run_poise_test('test').with(npm_binary: '/npm') }
      end # /context with a parent

      context 'without a parent' do
        recipe do
          poise_test 'test' do
            extend RSpec::Matchers
            extend RSpec::Mocks::ExampleMethods
            expect(PoiseLanguages::Utils).to receive(:which).with('node').and_return('/something/node')
          end
        end

        it { is_expected.to run_poise_test('test').with(npm_binary: '/something/npm') }
      end # /context without a parent
    end # /describe #npm_binary
  end # /describe PoiseJavascript::JavascriptCommandMixin::Resource

  describe PoiseJavascript::JavascriptCommandMixin::Provider do
  end # /describe PoiseJavascript::JavascriptCommandMixin::Provider
end
