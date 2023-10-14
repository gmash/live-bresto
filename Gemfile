# frozen_string_literal: true

source 'https://rubygems.org'

gem 'cocoapods'
gem 'danger'
gem 'fastlane'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
# dependabotでGemfileの解析に失敗する問題の回避策として、パスを直書きしている。
# 詳細は https://github.com/dependabot/dependabot-core/issues/1720#issuecomment-600831687
eval_gemfile('fastlane/Pluginfile') if File.exist?(plugins_path)
