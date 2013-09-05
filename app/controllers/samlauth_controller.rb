

class SamlauthController < ApplicationController
  def index 
    @auth = ::Base64.decode64(params[:saml])
    @auth = PHP.unserialize(@auth) 
    session[:current_user_id] = @auth["login-id"][0]
    session[:logged_in] = true
    redirect_to "/"

  end

  def logout 
    session[:current_user_id] = nil
    session[:logged_in] = false
    redirect_to "/"

  end
end

# class SamlauthController < ApplicationController
#         def index 
#                 @auth = ::Base64.decode64(params[:saml])
#                 @auth = PHP.unserialize(@auth) 
#                 @entry = ContestEntry.new();
#                 @entry.login_id = @auth["login-id"].to_s.gsub(/[^0-9A-Za-z.@_]/, '')
#                 @entry.first_name = @auth["first-name"].to_s.gsub(/[^0-9A-Za-z.@_]/, '')
#                 @entry.last_name = @auth["last-name"].to_s.gsub(/[^0-9A-Za-z.@_]/, '')
#                 @entry.email = @auth["email"].to_s.gsub(/[^0-9A-Za-z.@_]/, '')
#                 @entry.saml_data = @auth
#                 @entry.save()
#     session[:current_user_id] = @auth["login-id"]
#     redirect_to "/entry_successful"
#         end
# end