require 'spec_helper'
require "logstash/filters/user_data"

describe LogStash::Filters::UserData do

   before do 
    @user_entries = [{
      'api_key' => 'notarealkey',
      'full_name' => 'Foo Bar',
      'company' => 'foo',
      'email' => 'foo@bar.com',
      'created_at' => '2015-04-01T19:17:00+00:00'
    }]
    @filter = LogStash::Filters::UserData.new({"user_entries" => @user_entries, "index_name" => "not_a_real_index"})
  end

  describe '#filter' do
    it 'returns the processed event' do
      test_event = {'api_key' => 'notarealkey'}
      expected_event = @user_entries[0]
      expect(@filter).to receive(:filter_matched) do |processed_event|
        expect(processed_event.to_hash).to include(expected_event)
      end
      @filter.filter(LogStash::Event.new(test_event))
    end
  end

  describe '#get_user_entries' do 
    it 'returns the correct array of user fields' do
      test_response = '{"hits": {"hits": [{"_source": 
        {"api_key":"notarealkey", 
         "full_name":"Foo Bar", 
         "company":"foo", 
         "email":"foo@bar.com", 
         "created_at":"2015-04-01T19:17:00+00:00"}}]}}'
      allow(@filter).to receive_message_chain(:open, :read) { test_response }
      allow(@filter).to receive(:get_users_count) { '1' }
      expect(@filter.get_user_entries).to match_array(@user_entries)

    end
  end

  describe '#get_users_count' do
    it 'returns the correct User count from ES index' do
      allow(@filter).to receive_message_chain(:open, :read) { '{"count": "7"}' }
      expect(@filter.get_users_count).to eq('7')
    end
  end
end
