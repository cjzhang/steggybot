require 'cinch'
class YaBish
  include Cinch::Plugin
  class << self
    attr_reader :ya_bish_array
  end

  listen_to :channel
  @ya_bish_array = ["Me and my niggas tryna get it, ya bish",
                    "Hit this house lick tell me is you with it, ya bish",
                    "From nine to five I know its vacant, ya bish",
                    "Hot sauce all in our Top Ramen, ya bish",
                    "Parked the car and then we start rhyming, ya bish",
                    "You looking like an easy come up, ya bish",
                    "A silver spoon I know you come from, ya bish",
                    "Back to reality we poor, ya bish",
                    "Another casualty at war, ya bish",
                    "He said one day I'd be on tour, ya bish",
                    "Gang signs out the window, ya bish",
                    "Hoping all of em offend you, ya bish",
                   ]


  def listen(m)
    ya_bish = /ya bish|steggybot/.match m.message
    m.reply YaBish.ya_bish_array.sample if ya_bish
  end
end

