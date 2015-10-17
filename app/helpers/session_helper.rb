module SessionHelper

	def signed_in?
		!current_user.nil?
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		token = session[:gc_token]
		@current_user ||= Organisation.find_by(access_token: token)
	end

	def current_user?(user)
		user == current_user
	end

	def logged_in_user
		unless current_user
			store_location
			redirect_to authorise_connect_path
		end
	end

	def store_location
		session[:return_to] = request.url if request.get?
	end

	def after_sign_in_path
		redirect = session[:return_to]
		session.delete(:return_to)
		redirect || reporting_path
	end

	def redirect_flow_session_token
		session[:redirect_flow_token] = SecureRandom.urlsafe_base64(nil, false) if session[:redirect_flow_token].nil?
		session[:redirect_flow_token]
	end

	def delete_redirect_flow_session_token
		session.delete(:redirect_flow_token)
	end
end
