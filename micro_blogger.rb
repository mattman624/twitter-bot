require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end

  def dm(target, message)
    puts "Tweeting #{target}...."
    message = "d @#{target} #{message}"
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }

    if screen_names.include?(target)
      tweet(message)
    else
      puts "Can't message that user"
    end
  end

  def follower_list
    user_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    user_names
  end

  def friends_last_tweets
    user_names = follower_list    
    messages = user_names.collect { |user_name| @client.user(user_name).status }
    messages.each do |message|
      puts "#{message.text}  from #{message.user.screen_name}"
    end
  end

  def run
    puts "Matt's Twitter client is running"
    command = ""
    while command !="q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]

      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then friends_last_tweets
        when 's' then puts shorten(parts[1])
        when 'turl' then tweet_with_url(parts[1..-2].join(" "), parts[-1])
        else
          puts "Sorry, #{command} is not a valid command"
      end
    end
  end

  def shorten(original_url)
    bitly ||= Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    short_url = bitly.shorten('http://' + original_url).short_url
  end

  def spam_my_followers(message)
    user_names = follower_list
    user_names.each do |user_name|
      dm(user_name, message)
    end
  end

  def tweet_with_url(main_message, url)
    short_url = shorten(url)
    tweet = "#{main_message} #{short_url}"
    tweet(tweet)
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
      puts "tweet sent"
    else
      puts "Message too long to tweet"
    end
  end


end

blogger = MicroBlogger.new
blogger.run
