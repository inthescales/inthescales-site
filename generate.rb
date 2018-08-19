require 'erb'
require 'json'

class PageData
    
    attr_accessor :blocks, :data, :project
    
    def initialize
        @blocks = {}
        @data = {}
        
        read_blocks
        read_data
    end
    
    def read_blocks
        
        Dir.foreach('blocks') do |item|
            next if item == '.' or item == '..'
            name = item.split(".")[0]
            contents = File.read("blocks/" + item)
            @blocks[name] = contents
        end
    end
    
    def read_data
        data["projects"] = {}
        Dir.foreach('data/projects/meta') do |item|
            next if item == '.' or item == '..'
            contents = File.read('data/projects/meta/' + item)
            parsed = JSON.parse(contents)
            name = item.split(".")[0]
            @data["projects"][name] = parsed
            
            if parsed["body"] != nil
               contents = File.read('data/projects/contents/' + parsed["body"]) 
                parsed["body"] = contents
            end
        end
    end
    
    def get_binding
        return binding()
    end
end

data = PageData.new
binding = data.get_binding

%x( rm -r output/*)

Dir.foreach('templates/core') do |item|
    next if item == '.' or item == '..'
    template = File.read("templates/core/" + item)
    output = ERB.new(template).result(binding)
    File.write("output/" + item, output)
end

%x( mkdir output/projects/ )

data.data["projects"].each do |index, project|
    data.project = data.data["projects"][index]
    template = File.read("templates/projects/" + project["template"])
    output = ERB.new(template).result(binding)
    File.write("output/projects/" + index + ".html", output)
end

%x( cp style.css output/style.css )
%x( cp -r resources/ output/resources )
