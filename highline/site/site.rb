require "rubygems"
require "ruport"

class Site < Ruport::Report

  PROJECT_PAGE = "http://rubyforge.org/projects/highline"
  DOCS         = "http://highline.rubyforge.org/docs"
  SVN_WEB      = "http://rubyurl.com/C4n"
  FILES        = "http://rubyforge.org/frs/?group_id=683"
   
  def sidebar
    render %{
       * "Project Page":#{PROJECT_PAGE}
       * "Documentation":#{DOCS}
       * Examples
       * "Download Source":#{FILES}
       * "SVN Browser":#{SVN_WEB}
     }, :filters => [ :red_cloth ]
  end

  def content
    render %{
      h2. HighLine is about...
      
      h3. Saving time.

      Command line interfaces are meant to be easy.  So why shouldn't building
      them be easy, too?  HighLine provides a solid toolset to help you get
      the job done cleanly so you can focus on the real task at hand, 
      _your task_

      h3. Clean and intuitive design.

      Want to get a taste for how HighLine is used?  Take a look at this simple
      example, which asks a user for a zip code, automatically does validation,
      and returns the result:

    } + '
        zip = ask("Zip?  ") { |q| q.validate = /\A\d{5}(?:-?\d{4})?\Z/ }
        ' + %{
      h3. Hassle-free Installation

      Installation is easy via RubyGems.  Simply enter the command:

        sudo gem install highline

      and you'll be on your way! Of course, manual installation is an option,
      too.
    }, :filters => [ :red_cloth ]
  end
 
  def build
    @report = render File.read("index.rhtml"), :filters => [ :erb ]
    @file   = "index.html"
    generate_report
  end
   
  
end

Site.new.build
