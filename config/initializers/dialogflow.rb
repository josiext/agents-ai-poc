require "google/cloud/dialogflow/cx/v3"

module Dialogflow
  PROJECT  = ENV.fetch("GOOGLE_CLOUD_PROJECT_ID")
  LOCATION = ENV.fetch("DIALOG_FLOW_CX_LOCATION", "global")
  AGENT_ID = ENV.fetch("DIALOG_FLOW_CX_AGENT_ID")

  def self.client
    @client ||= Google::Cloud::Dialogflow::CX::V3::Sessions::Client.new
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
