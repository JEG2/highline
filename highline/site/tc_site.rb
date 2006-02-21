require "test/unit"
require "rubygems"
require "site"

class TestSite < Test::Unit::TestCase
  
  def test_generate_page
    
    Site.new.generate_page("hello world","apple")
    assert_equal("hello world\n", File.read("apple"))

    Site.new.generate_page("goodbye\n moon\n","banana")
    assert_equal("goodbye\n moon\n", File.read("banana"))
  end
  
  def teardown
    FileUtils.rm("apple")
    FileUtils.rm("banana")
  end
    
end
