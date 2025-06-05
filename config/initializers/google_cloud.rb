if Rails.env.development? || Rails.env.production?
  unless ENV['GOOGLE_CLOUD_PROJECT_ID']
    Rails.logger.warn "GOOGLE_CLOUD_PROJECT_ID not set. Google Cloud AI Platform v2 endpoint may not work."
  end

  unless ENV['GOOGLE_CLOUD_LOCATION']
    Rails.logger.warn "GOOGLE_CLOUD_LOCATION not set. Defaulting to us-central1."
  end

  Rails.logger.info "Google Cloud AI Platform configuration:"
  Rails.logger.info "  Project ID: #{ENV['GOOGLE_CLOUD_PROJECT_ID'] || 'not set'}"
  Rails.logger.info "  Location: #{ENV['GOOGLE_CLOUD_LOCATION'] || 'us-central1 (default)'}"
  Rails.logger.info "  Credentials: #{ENV['GOOGLE_APPLICATION_CREDENTIALS'] ? 'Service Account File' : 'Application Default Credentials'}"
end 