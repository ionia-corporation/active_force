require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_force'
Dir["./spec/support/**/*"].sort.each { |f| require f }
require 'pry'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural 'quota', 'quotas'
  inflect.plural 'Quota', 'Quotas'
  inflect.singular 'quota', 'quota'
  inflect.singular 'Quota', 'Quota'
end

RSpec.configure do |config|
  config.order = :random
  config.include RestforceFactories
end
