require "test/unit"
require "rubygems"
require "site"

class TestSite < Test::Unit::TestCase
  
  def test_generate_page
    
    Site.new.generate_page("hello world","apple")
    assert_equal("<p>hello world</p>\n", File.read("apple"))

    Site.new.generate_page("_goodbye_\n moon\n","banana")
    assert_equal("<p><em>goodbye</em>\n moon</p>\n", File.read("banana"))
  end
  
  def teardown
    FileUtils.rm("apple")
    FileUtils.rm("banana")
  end
    
end
