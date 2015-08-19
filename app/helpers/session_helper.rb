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
end
