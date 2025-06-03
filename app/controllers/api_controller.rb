class ApiController < ApplicationController
  # GET /api/hello
  def hello_world
    render json: { message: "hola mundos" }
  end
end 