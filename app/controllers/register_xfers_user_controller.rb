require 'uri'
require 'net/http'

class RegisterXfersUserController < ApplicationController
  protect_from_forgery prepend: true

  APP_API_KEY = 'HPFsP1cFD597nLnx_tB3NhDsxLxSzzTFXSCqyPoLQ7E'
  APP_SECRET_KEY = "MvaH9btx5nC2vEr85C2YkzF2LQt5wiAWKz2AJxSd8Bo"

  def retrieve_phone_number
    response = call_xfers_signup_login_api(params["phoneNumber"])

    render :json => JSON.parse(response.body)
  end

  def retrieve_otp
    # FIXME: phone number must be supplied by the SDK
    phone_number = "+6287785725657"
    otp = params["OTP"]

    response = call_xfers_get_token_api(phone_number, otp)

    user_api_token = JSON.parse(response.body)["user_api_token"]

    # You should save this token in your database
    Rails.logger.info "#{phone_number} #{user_api_token}"

    render :json => {
      "apiKey" => user_api_token
    }
  end

  private def call_xfers_signup_login_api(phone_number)
    signature = Digest::SHA1.hexdigest("#{phone_number}#{APP_SECRET_KEY}")

    url = URI("https://sandbox-id.xfers.com/api/v3/authorize/signup_login")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["X-XFERS-APP-API-KEY"] = APP_API_KEY
    request["Content-Type"] = 'application/json'
    request.body = "{\n\t\"phone_no\": \"+6287785725657\",\n\t\"signature\": \"#{signature}\"\n}"

    response = http.request(request)
  end

  private def call_xfers_get_token_api(phone_number, otp)
    signature = Digest::SHA1.hexdigest("#{phone_number}#{otp}#{APP_SECRET_KEY}")
    encoded_phone_number = URI.encode_www_form_component(phone_number)

    url = URI("https://sandbox-id.xfers.com/api/v3/authorize/get_token?otp=#{otp}&phone_no=#{encoded_phone_number}&signature=#{signature}")

    http = Net::HTTP.new(url.hogst, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["X-XFERS-APP-API-KEY"] = APP_API_KEY
    request["Content-Type"] = 'application/x-www-form-urlencoded'

    response = http.request(request)
  end
end
