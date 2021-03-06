class NetworksController < ApplicationController
  # GET /networks
  # GET /networks.json
  def index
    @networks = Network.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @networks }
    end
  end

  # GET /networks/1
  # GET /networks/1.json
  def show
    @network = Network.find_by_slug(params[:id])

    unless params[:year].nil? and params[:month].nil? and params[:day].nil?
      @date = Time.parse(params[:year]+"-"+params[:month]+"-"+params[:day])
      p "Found date in URL: "+@date.to_s
    else
      @date = Time.now
      p "Take current time: "+@date.to_s
    end

    @events = Event.where('facebook_event.start_time' => {'$gt' => @date, '$lt' => (@date+1.day)}).asc('facebook_event.start_time').page params[:page]

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @events }
    end
  end

  def deals
    authorize! :manage, :all

    @network = Network.find_by_slug(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @network }
    end
  end

  def update_groups
    authorize! :manage, :all
    
    Resque.enqueue(UpdateGroups)
    render :nothing => true
  end

  def clear_queue
    authorize! :manage, :all

    p "Beforing clearing queue: "+Qu.length.to_s
    Qu.clear
    p "Cleared queue: "+Qu.length.to_s
    render :nothing => true
  end

  # GET /networks/new
  # GET /networks/new.json
  def new
    authorize! :manage, :all

    @network = Network.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @network }
    end
  end

  # GET /networks/1/edit
  def edit
    authorize! :manage, :all

    @network = Network.find_by_slug(params[:id])
  end

  # POST /networks
  # POST /networks.json
  def create
    authorize! :manage, :all

    @network = Network.new(params[:network])

    respond_to do |format|
      if @network.save
        format.html { redirect_to @network, notice: 'Network was successfully created.' }
        format.json { render json: @network, status: :created, location: @network }
      else
        format.html { render action: "new" }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /networks/1
  # PUT /networks/1.json
  def update
    authorize! :manage, :all

    @network = Network.find_by_slug(params[:id])

    respond_to do |format|
      if @network.update_attributes(params[:network])
        format.html { redirect_to @network, notice: 'Network was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    authorize! :manage, :all

    @network = Network.find(params[:id])
    @network.destroy

    respond_to do |format|
      format.html { redirect_to networks_url }
      format.json { head :no_content }
    end
  end
end
