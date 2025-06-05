require 'ruby_llm'

RubyLLM.configure do |config|
  config.gemini_api_key = ENV.fetch('GEMINI_API_KEY', nil)
  config.default_model  = "gemini-2.0-flash-thinking-exp"
end

