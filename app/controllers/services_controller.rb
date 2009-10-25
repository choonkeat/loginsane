class ServicesController < ApplicationController
  before_filter :require_admin_user
  before_filter :set_site
  # GET /services
  # GET /services.xml
  def index
    @services = @site.services.configured

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @services }
    end
  end

  # GET /services/1
  # GET /services/1.xml
  def show
    return redirect_to(site_services_path(@site))

    @service = @site.services.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service }
    end
  end

  # GET /services/new
  # GET /services/new.xml
  def new
    # we need an existing record to churn out a callback url, for registration
    @service = @site.services.notconfigured.first || @site.services.create!
    return redirect_to edit_site_service_path(@site, @service, :auth_type => params[:auth_type])
  end

  # GET /services/1/edit
  def edit
    @service = @site.services.find(params[:id])
    @service.auth_type ||= params[:auth_type]
  end

  # PUT /services/1
  # PUT /services/1.xml
  def update
    @service = @site.services.find(params[:id])

    respond_to do |format|
      if @service.update_attributes(params[:service])
        flash[:notice] = 'Service was successfully updated.'
        format.html { redirect_to([@site, @service]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    @service = @site.services.find(params[:id])
    @service.destroy

    respond_to do |format|
      format.html { redirect_to(site_services_url(@site)) }
      format.xml  { head :ok }
    end
  end

protected
  def set_site
    @site = Site.find_by_slug(params[:site_id]) unless params[:site_id].blank?
  end
end
