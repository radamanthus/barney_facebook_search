require 'fb_graph'

def clean_output
  system 'rm -rf *jpg*'
  system 'rm -rf *.html'
end

def get_newest_jpeg(dir, existing_jpegs)
  jpegs = Dir.new(dir).entries.select{|f| f.include?('jpg')}
  return (jpegs - existing_jpegs).first
end

def main(search_string, output_filename)
  clean_output
  
  output = File.new(output_filename, 'w+')
  results = FbGraph::Searchable.search(search_string).
    select{|r| r['type'] && 'status' == r['type']}.
    select{|r| r['from'] && r['from']['id']}
  
  output.puts "<html><body>"
  output.puts "<table border=1><tr><th>Name</th>Status</th><th>&nbsp;</th>"
  user_pics = []
  results.each do |r|
    user = FbGraph::User.fetch(r['from']['id'])
    status = 
    system "wget #{user.picture}"
    pic = get_newest_jpeg(".", user_pics)
    user_pics << pic
    output.puts %{
      <tr>
        <td><a href="#{user.link}"><img src="#{pic}"></a></td>
        <td><a href="#{user.link}">#{user.name}</a></td>
        <td>#{r['message']}</td>        
      </tr>
    }
  end
  output.puts "</table>"
  output.puts "</body></html>"  
  
  output.close
end

main(ARGV[0], ARGV[1])