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

describe PoiseJavascript::Resources::NpmInstall do
  step_into(:npm_install)
  let(:expect_cmd) { [] }
  let(:expect_output) { '' }
  before do
    allow(PoiseLanguages::Utils).to receive(:which).with('node').and_return('/node')
    expect_any_instance_of(described_class::Provider).to receive(:javascript_shell_out!).with(*expect_cmd).and_return(double(stdout: expect_output))
  end

  context 'with a path' do
    let(:expect_cmd) { [%w{/npm install --production --unsafe-perm true}, {cwd: '/myapp', user: nil, group: nil, environment: {'PATH' => "/:#{ENV['PATH']}"}, timeout: 900}] }
    recipe do
      npm_install '/myapp'
    end

    it { is_expected.to install_npm_install('/myapp') }
  end # /context with a path

  context 'with a user' do
    let(:expect_cmd) { [%w{/npm install --production --unsafe-perm true}, {cwd: '/myapp', user: 'myuser', group: nil, environment: {'PATH' => "/:#{ENV['PATH']}"}, timeout: 900}] }
    recipe do
      npm_install '/myapp' do
        user 'myuser'
      end
    end

    it { is_expected.to install_npm_install('/myapp') }
  end # /context with a user

  context 'with production false' do
    let(:expect_cmd) { [%w{/npm install --unsafe-perm true}, {cwd: '/myapp', user: nil, group: nil, environment: {'PATH' => "/:#{ENV['PATH']}"}, timeout: 900}] }
    recipe do
      npm_install '/myapp' do
        production false
      end
    end

    it { is_expected.to install_npm_install('/myapp') }
  end # /context with production false

  context 'with unsafe_perm false' do
    let(:expect_cmd) { [%w{/npm install --production --unsafe-perm false}, {cwd: '/myapp', user: nil, group: nil, environment: {'PATH' => "/:#{ENV['PATH']}"}, timeout: 900}] }
    recipe do
      npm_install '/myapp' do
        unsafe_perm false
      end
    end

    it { is_expected.to install_npm_install('/myapp') }
  end # /context with unsafe_perm false

  context 'with unsafe_perm nil' do
    let(:expect_cmd) { [%w{/npm install --production}, {cwd: '/myapp', user: nil, group: nil, environment: {'PATH' => "/:#{ENV['PATH']}"}, timeout: 900}] }
    recipe do
      npm_install '/myapp' do
        @unsafe_perm = nil
      end
    end

    it { is_expected.to install_npm_install('/myapp') }
  end # /context with unsafe_perm nil

  context 'with output' do
    let(:expect_cmd) { [%w{/npm install --production --unsafe-perm true}, {cwd: '/myapp', user: nil, group: nil, environment: {'PATH' => "/:#{ENV['PATH']}"}, timeout: 900}] }
    let(:expect_output) { <<-EOH }
express@4.13.3 node_modules/express
├── escape-html@1.0.2
├── merge-descriptors@1.0.0
├── array-flatten@1.1.1
├── cookie@0.1.3
├── cookie-signature@1.0.6
├── utils-merge@1.0.0
├── methods@1.1.1
├── fresh@0.3.0
├── range-parser@1.0.2
├── path-to-regexp@0.1.7
├── vary@1.0.1
├── content-type@1.0.1
├── etag@1.7.0
├── parseurl@1.3.0
├── content-disposition@0.5.0
├── serve-static@1.10.0
├── depd@1.0.1
├── qs@4.0.0
├── on-finished@2.3.0 (ee-first@1.1.1)
├── finalhandler@0.4.0 (unpipe@1.0.0)
├── debug@2.2.0 (ms@0.7.1)
├── proxy-addr@1.0.8 (forwarded@0.1.0, ipaddr.js@1.0.1)
├── send@0.13.0 (destroy@1.0.3, statuses@1.2.1, ms@0.7.1, mime@1.3.4, http-errors@1.3.1)
├── type-is@1.6.8 (media-typer@0.3.0, mime-types@2.1.6)
└── accepts@1.2.12 (negotiator@0.5.3, mime-types@2.1.6)
EOH
    recipe do
      npm_install '/myapp'
    end

    it { is_expected.to install_npm_install('/myapp') }
    it { expect(chef_run.npm_install('/myapp').updated?).to be true }
  end # /context with output
end
