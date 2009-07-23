class Step4Controller < ApplicationController

  def show
    @registrant = Registrant.find(params[:registrant_id])
  end

  def update
  end
end
