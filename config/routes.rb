Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post "register_xfers_user/signup_login" => "register_xfers_user#retrieve_phone_number"
  post "register_xfers_user/get_token"  => "register_xfers_user#retrieve_otp"
end
