require 'lib/git_data.rb'
require 'erb'

# Uses rss.xml.erb to generate an rss feed showing the repository's tags
# and the diff stats against the previous tag
# Usage
#   rxml = ERB.new(File.read 'lib/rss.xml.erb')
#   tags = GitTagsRss.new('/path/to/repo')
#   result = rxml.result tags.get_binding
#   File.open("/path/to/repo/gittags.rss", 'w') {|f| f.write(result)}

class GitTagsRss < GitData
  
  attr_accessor :items
  
  def initialize(path, params = {})
    # params:
    #   repository
    #   url
    #   pubDate
    super path
    @title       = "#{params['repository']} commits"
    @description = "Git tags and diff statitistics history for #{params['repository']}"
    @url         = "#{params['url']}"
    @pubDate     = params['pubDate'] || Time.now
    @items       = get_items
  end
  
  def get_items
    items = []
    tags = get_tags(true, true).reverse
    tags.each do |tag|
      item = {}
      item['title']       = "Tag ref: #{tag['ref']} by #{tag['tagger'].gsub('<', '(').gsub('>',')')}"
      item['description'] = "Information about #{tag['ref']}"
      item['content']     = "<pre>#{tag['diff']}</pre>"
      item['url']         = @url
      item['guid']        = tag['rev']
      item['date']        = tag['date']
      items << item
    end
    items
  end
  
  def get_binding
    binding
  end
  
end