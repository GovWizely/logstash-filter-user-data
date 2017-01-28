# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "open-uri"
require "json"

class LogStash::Filters::UserData < LogStash::Filters::Base

  config_name "user_data"

  config :user_entries, :validate => :array, :default => []
  config :index_name, :validate => :string, :required => true

  public
  def register
    @user_entries = get_user_entries if @user_entries.empty?
  end

  public
  def filter(event)
    if event.get('api_key')
      new_info = @user_entries.find { |user| user["api_key"] == event.get('api_key') }
      if new_info
        event.set("full_name", new_info["full_name"])
        event.set("email", new_info["email"])
        event.set("company", new_info["company"])
        event.set("created_at", new_info["created_at"])
      end
    end
    filter_matched(event)
  end

  def get_user_entries
    user_count = get_users_count
    user_response = open("http://localhost:9200/#{index_name}/_search?size=#{user_count}&q=*:*").read
    user_response_hashes = JSON.parse(user_response)
    user_info_keys = ["api_key", "full_name", "email", "company", "created_at"]
    user_response_hashes["hits"]["hits"].map do |entry|
      entry["_source"].select {|k, v| user_info_keys.include?(k) } 
    end
  end

  def get_users_count
    user_count_response = open("http://localhost:9200/#{index_name}/_count?q=*:*").read
    JSON.parse(user_count_response)["count"]
  end
end
