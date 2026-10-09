class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :devise_controller?

  # Devise-passwordless defaults to root_path, which requires auth and would
  # immediately bounce back to sign-in, clobbering the "check your email"
  # flash before it's ever shown. Send them back to the sign-in page instead.
  def after_magic_link_sent_path_for(resource_or_scope)
    new_user_session_path
  end
end
