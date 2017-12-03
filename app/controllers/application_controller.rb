class ApplicationController < ActionController::Base
  before_filter :check_ip

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include LoginsHelper

  def check_ip
    check_whitelist
    check_blacklist
  end

  def check_whitelist
    unless ENV['IP_WHITELIST'].blank?
      ips = ENV['IP_WHITELIST'].split(',')
      unless ips.include?(request.remote_ip)
        logger = Logger.new("#{Rails.root}/log/denied_requests.log")
        logger.fatal("Device not in IP whitelist blocked: #{request.remote_ip}")
        head 403
      end
    end
  end

  def check_blacklist
    unless ENV['IP_BLACKLIST'].blank?
      ips = ENV['IP_BLACKLIST'].split(',')
      if ips.include?(request.remote_ip)
        logger = Logger.new("#{Rails.root}/log/denied_requests.log")
        logger.fatal("Device in IP blacklist blocked: #{request.remote_ip}")
        head 403
      end
    end
  end
end