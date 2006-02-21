require "rubygems"
require "ruport"

class Site < Ruport::Report

  PROJECT_PAGE = "http://rubyforge.org/projects/highline"
  CONTACT      = "highline@stonecode.org"
  SVN_WEB      = "http://rubyurl.com/C4n"
  EXAMPLES     = "http://highline.rubyforge.org/examples.html"
  HOME         = "http://highline.rubyforge.org"

  def generate_page(string, file_name)
    @report = render string, :filters => [:erb, :red_cloth]
    @file   = file_name
    generate_report
  end

  def build
    generate_page(INDEX_CONTENT, "index.html")    
  end

# ----- Templates ------

INDEX_CONTENT = %{

  h1. Hello from Highline
    h2. Neat!

    * foo
    * bar

  See more on our "project page":#{PROJECT_PAGE}
  

}

EXAMPLES_CONTENT = %{


}
  

end

Site.new.build
