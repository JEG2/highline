# require  "rubygems"
require  "highline/system_extensions"

puts  "Press a key to view the corresponding ASCII code(s) (or CTRL-X to exit)."

loop  do
	print "=>  "
	char = HighLine::SystemExtensions.get_character
	case char
	when ?\C-x then print "Exiting...";  exit;
	else puts "#{char.chr}  [#{char}] (hex:#{char.to_s(16)})";
	end
end
