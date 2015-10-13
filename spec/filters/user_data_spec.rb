require 'spec_helper'
require "logstash/filters/user_data"

describe LogStash::Filters::UserData do

  describe '#get_users_count' do
    it 'returns the correct User count from ES index' do
      allow(LogStash::Filters::UserData).to receive_message_chain(:open, :read) { '{"count": "7"}' }
      expect(LogStash::Filters::UserData.get_users_count).to eq('7')
    end
  end


end
