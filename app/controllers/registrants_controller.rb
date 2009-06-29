class RegistrantsController < ApplicationController
  # GET /registrants
  # GET /registrants.xml
  def index
    @registrants = Registrant.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @registrants }
    end
  end

  # GET /registrants/1
  # GET /registrants/1.xml
  def show
    @registrant = Registrant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @registrant }
    end
  end

  # GET /registrants/new
  # GET /registrants/new.xml
  def new
    @registrant = Registrant.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @registrant }
    end
  end

  # GET /registrants/1/edit
  def edit
    @registrant = Registrant.find(params[:id])
  end

  # POST /registrants
  # POST /registrants.xml
  def create
    @registrant = Registrant.new(params[:registrant])

    respond_to do |format|
      if @registrant.save
        flash[:notice] = 'Registrant was successfully created.'
        format.html { redirect_to(@registrant) }
        format.xml  { render :xml => @registrant, :status => :created, :location => @registrant }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @registrant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /registrants/1
  # PUT /registrants/1.xml
  def update
    @registrant = Registrant.find(params[:id])

    respond_to do |format|
      if @registrant.update_attributes(params[:registrant])
        flash[:notice] = 'Registrant was successfully updated.'
        format.html { redirect_to(@registrant) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @registrant.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /registrants/1
  # DELETE /registrants/1.xml
  def destroy
    @registrant = Registrant.find(params[:id])
    @registrant.destroy

    respond_to do |format|
      format.html { redirect_to(registrants_url) }
      format.xml  { head :ok }
    end
  end
end
