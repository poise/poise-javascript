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

require 'poise/utils'
require 'poise_languages'


module PoiseJavascript
  # Mixin for resources and providers which run Javascript commands.
  #
  # @since 1.0.0
  module JavascriptCommandMixin
    include Poise::Utils::ResourceProviderMixin

    # Mixin for resources which run Javascript commands.
    module Resource
      include PoiseLanguages::Command::Mixin::Resource(:javascript, default_binary: 'node')

      # @!attribute npm_binary
      #   Path to the npm binary.
      #   @return [String]
      attribute(:npm_binary, kind_of: String, default: lazy { default_npm_binary })

      private

      # Find the default gem binary. If there is a parent use that, otherwise
      # use the same logic as {PoiseRuby::RubyProviders::Base#npm_binary}.
      #
      # @return [String]
      def default_npm_binary
        if parent_javascript
          parent_javascript.npm_binary
        else
          ::File.expand_path('../npm', javascript)
        end
      end
    end

    module Provider
      include PoiseLanguages::Command::Mixin::Provider(:javascript)
    end
  end
end
