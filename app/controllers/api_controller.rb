class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  
    # POST /process
    def agent_request
      begin
        text       = params.require(:instruction)
        session_id = params[:session_id].presence || SecureRandom.uuid
        context_data = params[:context_data]&.to_unsafe_h || {}
        
        prompt = Prompter.user(text, context_data)

        request = {
          session: Dialogflow.session_path(session_id),
          query_input: {
            text: { text: prompt },
            language_code: "es"
          }
        }

        response = Dialogflow.client.detect_intent request


        render json: {
          session_id: session_id,
          reply: response.query_result.response_messages
                            .map(&:text).flat_map(&:text).join(" ")
        }, status: :ok

      rescue => e
        render json: { 
          error: "Error al consultar Dialogflow",
          details: e.message,
          service: "Dialogflow"
        }, status: 500
      end
    end
end 