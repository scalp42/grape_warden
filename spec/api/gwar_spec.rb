require 'spec_helper'

describe GrapeWarden::API do
  include Rack::Test::Methods

  def app
    GrapeWarden::API
  end
    
  it "ping" do
    get "/ping"
    last_response.body.should == { :answer => "pong" }.to_json
  end

  context "unauthenticated" do
    it "info" do
      get "/info"
      last_response.status.should == 401
      last_response.body.should == { error: "Unauthorized" }.to_json
    end

    it "login" do
      post "/login", { "username" => "Susan" }
      last_response.status.should == 201
      last_response.body.should == { "username" => "Susan" }.to_json
    end

    it "invalid login" do
      post "/login", { "username" => "Invalid" }
      last_response.status.should == 401
      last_response.body.should == { error: "Invalid username or password" }.to_json
    end

    it "logged out" do
      post "/logout"
      last_response.status.should == 401
      last_response.body.should == { error: "Logged out" }.to_json      
    end
  end

  context "authenticated" do
    before do
      post "/login", { "username" => "Susan" }
    end
    it "info" do
      get "/info"
      last_response.status.should == 200
      last_response.body.should == { "username" => "Susan" }.to_json
    end
  end

  it "full cycle test" do
    get "/info"
    last_response.status.should == 401
    last_response.body.should == { error: "Unauthorized" }.to_json

    post "/login", { "username" => "Susan" }
    last_response.status.should == 201

    get "/info"
    last_response.status.should == 200
    last_response.body.should == { "username" => "Susan" }.to_json

    post "/logout"
    last_response.status.should == 201

    get "/info"
    last_response.status.should == 401
    last_response.body.should == { error: "Unauthorized" }.to_json      
  end
end

