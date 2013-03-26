require 'cinch'
require 'yaml'

class PlusPlus
  include Cinch::Plugin
  @help_hash = {
    :person => "Usage: !person NAME
Example: !person steggybot
Returns the plusplus values from all other users about user NAME",
    :persons_feelings => "Usage: !persons_feelings NAME
Example !persons_feelings steggybot
Returns the a hash of the people that that NAME has plusplus'ed, and the number of times."
  }
  match /karma (.*)/i, method: :lookup_sum
  listen_to :channel
  match /persons_feelings (.*)/i, method: :lookup_feelings
  match /person (.*)/i, method: :lookup

  # lookup looks up someone's name and replies with their karma in the
  # form:
  # czhang's karma: {"czhan.g"=>1}, {"skimbre.l"=>1}
  def lookup(m, name)
    values = plusplus_file
    # Don't want to always nameping people, so we mangle the name a little
    values = values.keys.map { |key| {mangle_string(key) => values[key][name]} if values[key][name] }.compact
    result = values.empty? ? ["no results"] : values
    result = "#{name}'s karma: " + result.join(", ")
    m.reply(result)
  end

  # This looks up someone's karma and replies with the total sum in
  # the form:
  # whunt: 9001
  def lookup_sum(m, name)
    values = plusplus_file
    values = values.keys.map { |key| {mangle_string(key) => values[key][name]} if values[key][name] }.compact
    if values.empty?
      m.reply("no results for #{name}")
    else
      total = values.map(&:values).flatten.inject(:+)
      m.reply("#{name}'s total karma: #{total}")
    end
  end

  # This looks up the people that someone has given karma to. It
  # replies in the form:
  # {"skimbre.l"=>-1, "czhan.g" => 1}
  def lookup_feelings(m, name)
    values = plusplus_file
    base_hash = (values.keys.include? name) ? values[name] : "no results"
    result = base_hash.keys.map {|key| [mangle_string(key), base_hash[key]] }
    result = Hash[result]
    m.reply(result)
  end

  # This mangles a name by inserting a '.'
  # It is used so this bot does not ping people multiple times
  def mangle_string(string)
    string.chop + "." + string[-1]
  end

  def initialize(*args)
    super
    @plusplus_file = config[:plusplus]
  end

  def listen(m)
    plusplus = %r{(?<to>(.*))\+\+$}.match m.message
    minusminus  = %r{(?<to>(.*))\-\-$}.match m.message
    change(m.user.nick, plusplus[:to], :+) if plusplus
    change(m.user.nick, minusminus[:to], :-) if minusminus
  end

  def plusplus_file()
    file = File.new(@plusplus_file, 'r')
    values = YAML.load(file.read)
    file.close
    values
  end

  def change(from, to, function)
    values = plusplus_file || {}
    froms_feelings = (values.keys.include? from) ? values[from] : Hash.new { |hash, key| hash[key] = 0 }
    p froms_feelings
    p to
    froms_feelings[to] = 0 if froms_feelings[to].nil?
    froms_feelings[to] = froms_feelings[to].send(function, 1)
    froms_feelings.delete(to) if froms_feelings[to] == 0
    values[from] = froms_feelings
    File.open(@plusplus_file, 'w') { |f| f.write (YAML.dump values) }
  end
end
