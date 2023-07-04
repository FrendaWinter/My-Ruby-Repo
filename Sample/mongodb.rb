require 'optparse'
require 'mongo'
require 'json'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: mongodb.rb [options]"

  opts.on("--server SERVER", "Server address") do |server|
    options[:server] = server
  end

  opts.on("--port PORT", "Server port") do |port|
    options[:port] = port
  end

  opts.on("--dbname DB", "Database name") do |db|
    options[:db] = db
  end

  opts.on("--user USER", "User") do |user|
    options[:user] = user
  end

  opts.on("--password PASSWORD", "Password") do |password|
    options[:password] = password
  end

  opts.on("--collection COLLECTION", "Database collection") do |collection|
    options[:collection] = collection
  end
  
  opts.on("--query QUERY", "Query document") do |query|
    options[:query] = query
  end
end.parse!

def get_db db_name
  begin
    puts "Connecting to mongo at: #{options[:server]}:#{options[:port]}"
    Mongo::Logger.logger.level = ::Logger::FATAL
    @db = Mongo::Client.new(
      [ "#{options[:server]}:#{options[:port]}" ],
      :database => "#{db_name}",
      :max_pool_size => 30,
      :wait_queue_timeout => 300,
      :socket_timeout => 300
      :user => options[:user] ,
      :password => options[:password],
      # :auth_mech => :scram,
      # :auth_source => 'admin'
    )
  rescue Exception => e
    puts "Exception! #{e.message}"
    puts "Failed to establish connection to the mongo server!"
    exit! false
  end
end 

# query feed in the database
def query_feed query_command
  field = ''
  query = ''
  find_using_regex = false
  case
    when query_command.match(/^\d+$/) then 
      field = "_id"
      query = query_command.to_s

    when query_command.match(/^[\w, \s, \., \*]+$/) then
      puts "asdfsdfsdfsdf"
      field = "description"
      query = /#{query_command}/i
      find_using_regex = true
  end

  get_db 'feeds'
  @collection = @db.database
  feed = @collection[:feed].find({field => query})
  feed.each {
    |doc|
    if find_using_regex
        puts "aaaaaaaaaaaaaa"
        if doc["description"].match(query_command)
            result = {
                :'_id' => doc["_id"],
                :'priority' => doc["priority"],
                :'type_id' => doc["type_id"],
                :'source_id' => doc["source_id"],
                :'description' => doc["description"],
                :'elements' => doc["elements"].first(5)
            }

            puts JSON.pretty_generate(JSON.parse(result.to_json))

            query_assos doc[:_id]
        end
    end

    result = {
        :'_id' => doc["_id"],
        :'priority' => doc["priority"],
        :'type_id' => doc["type_id"],
        :'source_id' => doc["source_id"],
        :'description' => doc["description"],
        :'elements' => doc["elements"].first(5)
    }

    puts JSON.pretty_generate(JSON.parse(result.to_json))

    query_assos doc[:_id]
  }
end