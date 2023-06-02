require_relative '../Utils/timeConverter.rb'

require 'test/unit'
require 'date'

class TestTimeConverter < Test::Unit::TestCase
    def test_time_converter
        assert_equal '04/17/2023', convertTimeString('2023-04-17', '%Y-%m-%d', '%m/%d/%Y')
        assert_equal '17-01-2023', convertTimeString('January 17, 2023', '%B %d, %Y', '%d-%m-%Y')
    end
end