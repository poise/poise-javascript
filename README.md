# Poise-Javascript Cookbook

[![Build Status](https://img.shields.io/travis/poise/poise-javascript.svg)](https://travis-ci.org/poise/poise-javascript)
[![Gem Version](https://img.shields.io/gem/v/poise-javascript.svg)](https://rubygems.org/gems/poise-javascript)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise-javascript.svg)](https://supermarket.chef.io/cookbooks/poise-javascript)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise-javascript.svg)](https://codecov.io/github/poise/poise-javascript)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise-javascript.svg)](https://gemnasium.com/poise/poise-javascript)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Chef](https://www.chef.io/) cookbook to provide a unified interface for
installing server-side JavaScript runtimes like Node.js and io.js.

## Quick Start

To install the latest available version of Node.js 0.12:

```ruby
javascript_runtime '0.12'
```

## Supported JavaScript Runtimes

This cookbook can install Node.js and io.js on Linux and OS X.

## Requirements

Chef 12 or newer is required.

## Attributes

Attributes are used to configure the default recipe.

* `node['poise-javascript']['install_nodejs']` – Install a Node.js runtime. *(default: true)*
* `node['poise-javascript']['install_iojs']` – Install an io.js runtime. *(default: false)*

## Recipes

### `default`

The default recipe installs Node.js or io.js based on the node attributes. It is
entirely optional and can be ignored in favor of direct use of the
`javascript_runtime` resource.

## Resources

### `javascript_runtime`

The `javascript_runtime` resource installs a JavaScript interpreter.

```ruby
javascript_runtime '0.12'
```

#### Actions

* `:install` – Install the JavaScript interpreter. *(default)*
* `:uninstall` – Uninstall the JavaScript interpreter.

#### Properties

* `version` – Version of the runtime to install. If a partial version is given,
  use the latest available version matching that prefix. *(name property)*

#### Provider Options

The `poise-javascript` library offers an additional way to pass configuration
information to the final provider called "options". Options are key/value pairs
that are passed down to the `javascript_runtime` provider and can be used to control how it
installs JavaScript. These can be set in the `javascript_runtime`
resource using the `options` method, in node attributes or via the
`javascript_runtime_options` resource. The options from all sources are merged
together in to a single hash.

When setting options in the resource you can either set them for all providers:

```ruby
javascript_runtime 'myapp' do
  version '0.10'
  options dev_package: false
end
```

or for a single provider:

```ruby
javascript_runtime 'myapp' do
  version '0.10'
  options :system, dev_package: false
end
```

Setting via node attributes is generally how an end-user or application cookbook
will set options to customize installations in the library cookbooks they are using.
You can set options for all installations or for a single runtime:

```ruby
# Global, for all installations.
override['poise-javascript']['options']['version'] = '0.10'
# Single installation.
override['poise-javascript']['myapp']['version'] = 'iojs'
```

The `javascript_runtime_options` resource is also available to set node attributes
for a specific installation in a DSL-friendly way:

```ruby
javascript_runtime_options 'myapp' do
  version 'iojs'
end
```

Unlike resource attributes, provider options can be different for each provider.
Not all providers support the same options so make sure to the check the
documentation for each provider to see what options the use.

### `javascript_runtime_options`

The `javascript_runtime_options` resource allows setting provider options in a
DSL-friendly way. See [the Provider Options](#provider-options) section for more
information about provider options overall.

```ruby
javascript_runtime_options 'myapp' do
  version 'iojs'
end
```

#### Actions

* `:run` – Apply the provider options. *(default)*

#### Properties

* `resource` – Name of the `javascript_runtime` resource. *(name property)*
* `for_provider` – Provider to set options for.

All other attribute keys will be used as options data.

### `javascript_execute`

The `javascript_execute` resource executes a JavaScript script using the configured runtime.

```ruby
javascript_execute 'myapp.js' do
  user 'myuser'
end
```

This uses the built-in `execute` resource and supports all the same properties.

#### Actions

* `:run` – Execute the script. *(default)*

#### Properties

* `command` – Script and arguments to run. Must not include the `node`. *(name attribute)*
* `javascript` – Name of the `javascript_runtime` resource to use. If not specified, the
  most recently declared `javascript_runtime` will be used. Can also be set to the
  full path to a `node` binary.

For other properties see the [Chef documentation](https://docs.chef.io/resource_execute.html#attributes).

### `node_package`

The `node_package` resource installs Node.js packages using
[NPM](https://www.npmjs.com/).

```ruby
node_package 'express' do
  version '4.13.3'
end
```

This uses the built-in `package` resource and supports the same actions and
properties. Multi-package installs are supported using the standard syntax.

#### Actions

* `:install` – Install the package. *(default)*
* `:upgrade` – Upgrade the package.
* `:remove` – Uninstall the package.

The `:purge` and `:reconfigure` actions are not supported.

#### Properties

* `group` – System group to install the package.
* `package_name` – Package or packages to install. *(name property)*
* `path` – Path to install the package in to. If unset install using `--global`.
  *(default: nil)*
* `version` – Version or versions to install.
* `javascript` – Name of the `javascript_runtime` resource to use. If not specified, the
  most recently declared `javascript_runtime` will be used. Can also be set to the
  full path to a `node` binary.
* `unsafe_perm` – Enable `--unsafe-perm`. *(default: true)*
* `user` – System user to install the package.

For other properties see the [Chef documentation](https://docs.chef.io/resource_package.html#attributes).
The `response_file`, `response_file_variables`, and `source` properties are not
supported.

### `npm_install`

The `npm_install` resource runs `npm install` for a package.

```ruby
npm_install '/opt/myapp'
```

The underlying `npm install` command will run on every converge, but notifications
will only be triggered if a package is actually installed.

#### Actions

* `:install` – Run `npm install`. *(default)*

#### Properties

* `path` – Path to the package folder containing a `package.json`. *(name attribute)*
* `group` – System group to install the packages.
* `javascript` – Name of the `javascript_runtime` resource to use. If not specified, the
  most recently declared `javascript_runtime` will be used. Can also be set to the
  full path to a `node` binary.
* `production` – Enable production install mode. *(default: true)*
* `unsafe_perm` – Enable `--unsafe-perm`. *(default: true)*
* `user` – System user to install the packages.

## Javascript Providers

### Common Options

These provider options are supported by all providers.

* `version` – Override the runtime version.

### `system`

The `system` provider installs Node.js using system packages. This is currently
only tested on platforms using `apt-get` and `yum` (Debian, Ubuntu, RHEL, CentOS
Amazon Linux, and Fedora). It may work on other platforms but is untested.

```ruby
javascript_runtime 'myapp' do
  provider :system
  version '0.10'
end
```

#### Options

* `dev_package` – Install the package with the headers and other development
  files. Can be set to a string to select the dev package specifically.
  *(default: true)*
* `package_name` – Override auto-detection of the package name.
* `package_upgrade` – Install using action `:upgrade`. *(default: false)*
* `package_version` – Override auto-detection of the package version.

### `scl`

The `scl` provider installs Node.js using the [Software Collections](https://www.softwarecollections.org/)
packages. This is only available on RHEL and CentOS. SCL offers more
recent versions of Node.js than the system packages for the most part. If an SCL
package exists for the requests version, it will be used in preference to the
`system` provider.

```ruby
javascript_runtime 'myapp' do
  provider :scl
  version '0.10'
end
```

### `nodejs`

The `nodejs` provider installs Node.js from the static binaries on nodejs.org.
Support is included for Linux and OS X.

```ruby
javascript_runtime 'myapp' do
  provider :nodejs
  version '0.12'
end
```

#### Options

* `path` – Folder to install Node.js to. *(default: /opt/nodejs-<version>)*
* `static_version` – Specific version number to use for computing the URL and
  path. *(default: automatic from `version`)*
* `strip_components` – Value to pass to tar --strip-components. *(automatic)*
* `url` – URL template to download the archive from. *(default: automatic)*

### `iojs`

The `iojs` provider installs io.js from the static binaries on iojs.org.
Support is included for Linux and OS X.

```ruby
javascript_runtime 'myapp' do
  provider :iojs
  version '3'
end
```

#### Options

* `path` – Folder to install io.js to. *(default: /opt/iojs-<version>)*
* `static_version` – Specific version number to use for computing the URL and
  path. *(default: automatic from `version`)*
* `strip_components` – Value to pass to tar --strip-components. *(automatic)*
* `url` – URL template to download the archive from. *(default: automatic)*

## Sponsors

The Poise test server infrastructure is sponsored by [Rackspace](https://rackspace.com/).

## License

Copyright 2015, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
