require_relative '../Data_Collecting/getLastModifyTime.rb'

require 'test/unit'
require 'date'

class TestGetLastModifyTime < Test::Unit::TestCase
    def test_get_last_modify_time
        assert_equal false, getLastModifiedTimeHttp('https://www.youtube.com/').nil?
    end
end


