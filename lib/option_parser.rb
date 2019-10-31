# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Style/IfInsideElse
class OptionParser
  # Parses ARGV from a Ruby script and returns options as a hash and
  # arguments as a list.
  #
  #   OptionParser.parse(%w(create -a 1 --username manfred chicken)) #=>
  #     [{"a => "1", "username"=>"manfred"}, ["create", "chicken"]]
  def self.parse(argv)
    return [{}, []] if argv.empty?

    options = {}
    rest = []
    name = nil

    # An array of arguments can contain three types of values:
    #
    # 1. A switch name, which starts with -- or -
    # 2. A switch value, when the last value was a switch.
    # 3. An argument that does not belong to a switch.
    argv.each do |value|
      bytes = value.bytes.first(2)
      # If the value start with '-', it's a switch.
      if bytes[0] == 45
        name = value.slice((bytes[1] == 45 ? 2 : 1)..-1)
        options[name] = nil
      else
        if name
          options[name] = value
          name = nil
        else
          rest << value
        end
      end
    end

    [options, rest]
  end
end

# rubocop:enable Metrics/MethodLength
# rubocop:enable Style/IfInsideElse
