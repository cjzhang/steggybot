require 'open-uri'
require 'cinch'
require 'nokogiri'

class TitleGrabber
  include Cinch::Plugin
  @help_string = "Titlegrabber simply sits in the channel watching for HTTP links. When it sees one, it will grab the title, and print it in the channel"
  listen_to :channel

  def grab(url)
    page = Nokogiri::HTML(open(url))
    return "This page doesn't appear to have a title" if page.css("title").nil?
    return page.css("title").first.text
  rescue OpenURI::HTTPError
    nil
  end

  def listen(m)
    urls = URI.extract(m.message, "http")
    urls.reject! {|url| url.include? "youtube.com"}
    titles = urls.map { |url| grab(url) }.compact
    unless titles.empty?
      m.reply titles.join(", ")
    end
  end
end
