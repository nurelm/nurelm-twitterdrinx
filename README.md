## Twitterthang

A simple app made for an interactive Twitter game during a Startup Drinks PGH event which will eventually consist of the following pieces:

  - ruby/search_tweets.rb: Meant to be run by a cron job. Pulls tweets based on the search specified and throws them into a SQLite3 DB
  - ruby/get_tweets.rb: A Sinatra app that provides a dirt simple API to pull a JSON object called "tweets" from the SQLite3 DB created by search_tweets.rb
  - index.html / app.js: An Angular page that pulls tweets using the API created by get_tweets.rb
  - Docker: The Dockerfile provided lets you run the whole sheebang as described below

This version of the project starts with `search_tweets.rb` and follows along with [this article](http://nurelm.com/twitterdrinx-a-game/).
