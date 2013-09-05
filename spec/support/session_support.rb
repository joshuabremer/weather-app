module SessionHelper   
  def set_session
    request.session[:user] = 1
  end
end

RSpec.configure do |config|
  config.include SessionHelper, :type => :controller
end