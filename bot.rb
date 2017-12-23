require 'discordrb'
require 'discordrb/webhooks'
require 'yaml'
require 'net/http'
require 'open-uri'
require 'json'

# read config 
config = YAML.load_file('config.yaml')

#discord bot token
TOKEN = config['discord_token']
PREFIX = config['discord_prefix']

bot = Discordrb::Commands::CommandBot.new token: TOKEN, prefix: PREFIX
#client = Discordrb::Webhooks::Client

def apiCall(request)
    url = 'https://fow.heihachi.pw/api/v1/card/name/'+URI.encode_www_form_component(request)
    #print url
    data = URI.parse(url).read

    #print url 
    #uri = URI(url)
    #req = Net::HTTP.new(uri)
    #req.use_ssl = true
    #res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    #    reply = http.request(req)
    #    puts "response: #{reply.body}"
    #end
end

bot.command(:plugin,description: "Show plug-in download link",usage: PREFIX+'plugin') do |_event, *args|
    args = args.join(' ')
    case args
        when 'fow'
            "https://downloads.heihachi.pw/fow/updatelist.txt"
        when 'casters'
            "https://downloads.heihachi.pw/casters/updatelist.txt"
        when 'darkest days'
            "Too be announced."
        else
            "https://downloads.heihachi.pw/fow/updatelist.txt"
    end
end

bot.command(:patreon,description: "Show donation links",usage: PREFIX+'patreon') do |_event, *args|
    args = args.join(' ')
    case args
        when 'heihachi'
            "https://www.patreon.com/heihachi/"
        when 'darkest days'
            "http://www.patreon.com/darkestdayscg/"
        else
            "http://www.patreon.com/darkestdayscg/"
    end
end

bot.command(:card, description: 'Search for a card',usage: 'card Cheshire Cat', min_args: 1) do |_event, *args|
    # embed needs to be called and setup 
    #bot.send_message(_event.channel.id, 'Test', false, true)
    search = apiCall(args.join(' '))
    search = JSON.parse(search)
    size = search.length
    #puts search[0]

    #title = title
    #description = description
    #url = url
    #timestamp = timestamp
    #colour = colour || color
    #footer = footer
    #image = image
    #thumbnail = thumbnail
    #video = video
    #provider = provider
    #author = author
    #fields = fields

    embed = Discordrb::Webhooks::Embed.new
    embed.title = search[0].fetch('name')
    #description = "`#{search[0].fetch('type')}` - `#{search[0].fetch('subtype')}`" if search[0].fetch('subtype')
    if search[0].fetch('subtype').empty?
        description = "`#{search[0].fetch('type')}`"
    else
        description = "`#{search[0].fetch('type')}` - `#{search[0].fetch('subtype')}`"
    end
    description = description+" ["+search[0].fetch('cost')+"]\n"+search[0].fetch('abilities')+"\n"+search[0].fetch('flavorText')
    embed.description = description
    embed.url = 'http://db.fowtcg.us/?p=card&code='+search[0].fetch('id')+'+'+search[0].fetch('rarity')
    embed.thumbnail = Discordrb::Webhooks::EmbedImage.new(url: search[0].fetch('cardLink'))
    _event.channel.send_message('',false,embed)
    #"Debug: `#{args.join(' ')}`:`#{size}` `#{search[0].fetch('name')}`"
end

bot.run

