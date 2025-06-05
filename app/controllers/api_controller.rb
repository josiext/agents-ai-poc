class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  # POST /process
  def process_request
    begin
      instruction = params[:instruction]
      prompt = Prompter.user(instruction)

      chat = RubyLLM.chat

      response = chat.ask prompt
      
      render json: { 
        message: response.content,
      }
    rescue => e
      render json: { 
        error: "Error al consultar Gemini",
        details: e.message 
      }, status: 500
    end
  end

  # POST /process_v2
  def process_v2_request
    begin
      require 'google/cloud/ai_platform/v1'

      # Create a client for the PredictionService
      client = Google::Cloud::AIPlatform::V1::PredictionService::Client.new

      # Set up the prediction request for text generation
      # Using Google's text-bison model for text generation
      project_id = ENV['GOOGLE_CLOUD_PROJECT_ID'] || 'your-project-id'
      location = ENV['GOOGLE_CLOUD_LOCATION'] || 'us-central1'
      publisher = 'google'
      model = 'text-bison'

      # Format the endpoint for the model
      endpoint = client.class.endpoint_path(
        project: project_id,
        location: location,
        publisher: publisher,
        model: model
      )

      # Prepare the prediction instances
      instances = [
        {
          prompt: "Saluda de manera amigable en español"
        }
      ]

      # Prepare the parameters for text generation
      parameters = {
        temperature: 0.7,
        maxOutputTokens: 256,
        topP: 0.8,
        topK: 10
      }

      # Make the prediction request
      response = client.predict(
        endpoint: endpoint,
        instances: instances,
        parameters: parameters
      )

      # Extract the generated text from the response
      if response.predictions && !response.predictions.empty?
        prediction = response.predictions.first
        generated_text = prediction["content"] || prediction["text"] || "No se pudo generar respuesta"
        
        render json: { 
          message: generated_text,
          service: "Google Cloud AI Platform"
        }
      else
        render json: { 
          error: "No se recibió respuesta del modelo",
          service: "Google Cloud AI Platform"
        }, status: 500
      end

    rescue => e
      render json: { 
        error: "Error al consultar Google Cloud AI Platform",
        details: e.message,
        service: "Google Cloud AI Platform"
      }, status: 500
    end
  end

  # POST /agent
  def agent_request
    begin
      text       = params.require(:instruction)
      session_id = params[:session_id].presence || SecureRandom.uuid

      request = {
        session: Dialogflow.session_path(session_id),
        query_input: {
          text: { text: text },
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