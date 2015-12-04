require 'twitter'
require 'sqlite3'
require 'yaml'

params = YAML.load_file('twitterdrinx.yml')

## Parameters to set
CONSUMER_KEY        = params['twitter_keys']['consumer_key']
CONSUMER_SECRET     = params['twitter_keys']['consumer_secret']
ACCESS_TOKEN        = params['twitter_keys']['access_token']
ACCESS_TOKEN_SECRET = params['twitter_keys']['access_token_secret']
SEARCH_QUERY        = params['search_query']

## Everything else
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end

tweets = client.search(SEARCH_QUERY)
begin
  db = SQLite3::Database.open File.dirname(__FILE__) + "/tweets.db"
  db.execute "CREATE TABLE IF NOT EXISTS tweets(" +
             "tweet_id INT UNIQUE ON CONFLICT IGNORE, " +
             "handle TEXT, " +
             "tweet_text TEXT, " +
             "num_favs INT, " +
             "num_rts INT, " +
             "img_url TEXT, " +
             "created_at DATETIME)"

  stmt = db.prepare "INSERT INTO tweets " +
                   "(tweet_id, handle, tweet_text, num_favs, " +
                   " num_rts, img_url, created_at) " +
                   "VALUES (?, ?, ?, ?, ?, ?, ?)"

  tweets.take(50).reverse_each do |tweet|

    if(tweet.media?)
      img_url = tweet.media[0].media_url.to_s
    else
      img_url = ''
    end

    puts "#{tweet.user.screen_name} (#{tweet.created_at}): " +
         "#{tweet.text} " +
         "[Favs: #{tweet.favorite_count}, " +
         "Retweets: #{tweet.retweet_count}, " +
         "ID: #{tweet.id}, Date: #{tweet.created_at},]" +
         "Img: #{img_url}"

    stmt.execute tweet.id, tweet.user.screen_name, tweet.text,
                 tweet.favorite_count, tweet.retweet_count,
                 img_url, tweet.created_at.to_s
  end
rescue SQLite3::Exception => e
  puts "DB exception occurred: "
  puts e
ensure
  stmt.close if stmt
  db.close if db
end
