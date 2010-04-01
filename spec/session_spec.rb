require 'spec_helper'

describe SimpleFacebook::Session do
  describe 'initialization' do
    it 'should require Facebook API key, secret, and session key' do
      SimpleFacebook::Session.new('asdfasdf', 'wertwert', 'qwerqwer').should be_a(SimpleFacebook::Session)
    end
  end
  
  describe 'making API calls' do
    before do
      @session = SimpleFacebook::Session.new('asdfasdf', 'wertwert', 'qwerqwer')
      @session.stub(:post).and_return('{"some": "json", "and": "stuff"}')
      @now = Time.at(1270161375)
      Time.stub(:now).and_return(@now)
    end
    
    it 'should convert a method_missing to a Facebook API method' do
      @session.should_receive(:facebook_call).with(
        'users.getInfo',
        :uids => '123,234,345',
        :fields => 'one,two,three'
      )
      
      @session.users_get_info(:uids => '123,234,345', :fields => 'one,two,three')
    end
    
    it 'should automatically post with the api key and session key, as well as call_id (set to current timestamp), v ("1.0"), and format ("JSON") params' do
      @session.should_receive(:post).with do |params|
        params[:method].should == 'users.getInfo'
        params[:api_key].should == 'asdfasdf'
        params[:session_key].should == 'qwerqwer'
        params[:call_id].should == @now.to_i
        params[:v].should == '1.0'
        params[:format].should == 'JSON'
        params[:uids].should == '123,234,345'
        params[:fields].should == 'one,two,three'
      end
      
      @session.users_get_info(:uids => '123,234,345', :fields => 'one,two,three')
    end
    
    it 'should automatically post with the correct signature, based on the api secret' do
      @session.should_receive(:post).with do |params|
        params[:sig].should == 'ec46df26b7e0bfbafddb5dbfa2c182d1'
      end
      
      @session.users_get_info(:uids => '123,234,345', :fields => 'one,two,three')
    end
    
    it 'should return the output parsed from JSON' do
      @session.users_get_info(:uids => '123,234,345', :fields => 'one,two,three').should == { 'some' => 'json', 'and' => 'stuff' }
    end
  end
end