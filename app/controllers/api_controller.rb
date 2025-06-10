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

        # Extraer texto de la respuesta
        response_text = response.query_result.response_messages
                                .map(&:text).flat_map(&:text).join(" ")

        # Buscar y extraer contenido JSON de bloques de código
        json_content = extract_json_from_response(response_text)

        render json: {
          session_id: session_id,
          reply: json_content || response_text
        }, status: :ok

      rescue => e
        render json: { 
          error: "Error al consultar Dialogflow",
          details: e.message,
          service: "Dialogflow"
        }, status: 500
      end
    end

    private

    def extract_json_from_response(text)
      # Buscar bloques de código JSON usando regex
      json_match = text.match(/```json\s*(.*?)\s*```/m)
      
      if json_match
        begin
          # Intentar parsear el JSON extraído
          JSON.parse(json_match[1])
        rescue JSON::ParserError => e
          Rails.logger.warn "Error parsing JSON from response: #{e.message}"
          nil
        end
      else
        nil
      end
    end
end 