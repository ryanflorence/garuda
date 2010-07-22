# GitData by Ryan Florence (http://ryanflorence.com) 
# Tangent off of a script by Chris Dinger: http://www.houseofding.com/2009/03/create-an-rss-feed-of-your-git-commits/
# 
# Parses some git messages into ruby objects


require 'time'

class GitData
  
  attr_accessor :path
  
  def initialize(path)
    @pwd = `pwd`.chomp
    @path = path
  end
  
  def get_tags(sort_by_date = true, diff_stat = false)
    # get list of tags
    tags = []
    Dir.chdir @path
    tag_refs = `git tag`.chomp.split("\n")
    
    # parse the tag notes and store the data
    tag_refs.each_with_index do |tag, i|
      notes     = `git show --stat #{tag}`
      tagger    = get_tagger notes
      date      = get_date notes
      time      = Time.parse date
      rev       = get_rev notes
      tags << { 'ref' => tag, 'date' => date, 'rev' => rev, 'time' => time, 'tagger' => tagger }
    end
    # Sort the tags by date
    tags.sort!{ |x,y| x['time'] <=> y['time'] } if sort_by_date
    
    if diff_stat
      tags.each_with_index do |tag, i|
        tag['diff'] = (i == 0) ? 'first tag, no diff' : `git diff --stat #{tag_refs[i - 1]}..#{tag['ref']}`
        tags[i] = tag
      end
    end
    
    Dir.chdir @pwd    
    return tags
  end
  
  def get_log(ref = 'master', max = 10)
    entries = []
    Dir.chdir(@path)
    log = `git log #{ref} --max-count=#{max} --name-status`.split("\ncommit ")
    Dir.chdir(@pwd)
    log.each do |entry|
      rev       = get_rev(entry)
      author    = get_author(entry)
      date      = get_date(entry)
      time      = Time.parse date
      comments  = get_comments(entry)
      entries << { 'rev' => rev, 'author' => author, 'date' => date, 'comments' => comments, 'time' => time }
    end
    return entries
  end
  
private

  def get_date(notes)
    notes.gsub(/^.*Date: +/ms, '').gsub(/\n.*$/ms, '')
  end
  
  def get_rev(notes)
    notes.gsub(/^.*commit /ms, '').gsub(/\n.*$/ms, '')
  end

  def get_tagger(notes)
    notes.match(/Tagger:/) ? notes.gsub(/^.*Tagger: /ms, '').gsub(/\n.*$/ms, '') : 'Anonymous'
  end
  
  def get_author(notes)
    notes.gsub(/^.*Author: /ms, '').gsub(/ <.*$/ms, '')
  end
  
  def get_comments(notes)
    notes.gsub(/^.*Date[^\n]*/ms, '')
  end
  
end