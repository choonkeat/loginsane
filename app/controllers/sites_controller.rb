class SitesController < ApplicationController
  before_filter :require_admin_user, :except => [:login, :logout, :preview]

  # GET /sites
  # GET /sites.xml
  def index
    @sites = Site.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  def preview
    @site = Site.find_by_slug(params[:id])
  end

  # this callback is specifically only for root site (i.e. Loginsane Control Panel)
  def login
    @site = Site.first
    signature = Digest::SHA1.hexdigest("#{params[:token]}#{@site.secret}")
    # it would've been cleaner to pull profile like any other website
    # but i'm afraid folks would run this app as ./script/server initially
    # and since that is a single-threaded/single-process server, pulling
    # profile from itself would result in a dead-lock. so instead, we're
    # retrieving the profile directly via db
    if false
      url = "#{request.protocol}#{request.host_with_port}/loginsane/profile.json?key=#{@site.key}&signature=#{signature}&token=#{params[:token]}"
      json_str = url(open) {|f| f.read }
      json_obj = JSON.parse(json_str)
    else
      profile = Profile.login(params[:token], signature)
      json_obj = profile && profile.json_object
    end

    # set the session based on profile info, if any
    if json_obj
      flash[:notice] = "Successfully logged in as a super-user"
      session[:profile_id] = json_obj["id"]
      session[:profile_name] = json_obj["displayName"] || json_obj["preferredUsername"] || "superuser"
    end
    redirect_to sites_path
  end

  def logout
    session[:profile_id] = nil
    session[:profile_name] = nil
    redirect_to sites_path
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find_by_slug(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end

  # GET /sites/new
  # GET /sites/new.xml
  def new
    @site = Site.new(:css => IO.read("#{Rails.root}/public/stylesheets/loginsane.css"))

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site }
    end
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find_by_slug(params[:id])
  end

  # POST /sites
  # POST /sites.xml
  def create
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        flash[:notice] = 'Site was successfully created.'
        format.html { redirect_to(@site) }
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.xml
  def update
    @site = Site.find_by_slug(params[:id])

    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'Site was successfully updated.'
        format.html { redirect_to(@site) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.xml
  def destroy
    @site = Site.find_by_slug(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to(sites_url) }
      format.xml  { head :ok }
    end
  end
end
