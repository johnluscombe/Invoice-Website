class IpAddressesController < ApplicationController
  def index
    @blacklists = BlacklistIpAddress.all
    @whitelists = WhitelistIpAddress.all
  end

  def create

  end

  def update

  end

  def destroy

  end
end
