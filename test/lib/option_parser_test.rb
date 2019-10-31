# frozen_string_literal: true

require_relative '../test_helper'
require 'option_parser'

class OptionParserTest < ActiveSupport::TestCase
  EXAMPLES = [
    [%w[], {}, %w[]],
    [%w[create], {}, %w[create]],
    [%w[-h -i], { 'h' => nil, 'i' => nil }, %w[]],
    [%w[-i 1], { 'i' => '1' }, %w[]],
    [%w[create -h],
     { 'h' => nil },
     %w[create]],
    [%w[create -h --username sjaak],
     { 'username' => 'sjaak', 'h' => nil },
     %w[create]],
    [%w[create -h --username sjaak --use-password secret -i -t 12],
     { 'username' => 'sjaak', 'use-password' => 'secret', 't' => '12', 'i' => nil, 'h' => nil },
     %w[create]]
  ].freeze

  test 'parses examples' do
    EXAMPLES.each do |input, options, rest|
      assert_equal [options, rest], OptionParser.parse(input)
    end
  end
end
