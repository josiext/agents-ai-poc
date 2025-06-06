require "google/cloud/dialogflow/cx/v3"

module Dialogflow
  PROJECT  = ENV.fetch("GOOGLE_CLOUD_PROJECT_ID")
  LOCATION = ENV.fetch("DIALOG_FLOW_CX_LOCATION", "global")
  AGENT_ID = ENV.fetch("DIALOG_FLOW_CX_AGENT_ID")

  def self.client
    @client ||= begin
      # Configure the client with the correct regional endpoint
      if LOCATION != "global"
        # For regional endpoints, configure the client with the regional API endpoint
        Google::Cloud::Dialogflow::CX::V3::Sessions::Client.new do |config|
          config.endpoint = "#{LOCATION}-dialogflow.googleapis.com"
        end
      else
        # For global endpoint, use default configuration
        Google::Cloud::Dialogflow::CX::V3::Sessions::Client.new
      end
    end
  end

  def self.session_path(session_id)
    client.session_path(
      project:  PROJECT,
      location: LOCATION,
      agent:    AGENT_ID,
      session:  session_id
    )
  end
end
