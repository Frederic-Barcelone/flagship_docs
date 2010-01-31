class CategoriesController < ApplicationController
  # GET /categories
  # GET /categories.xml
  def index
    @categories = Category.roots
    @categories.delete_if {|x| !x.allowed_to_read} #Hide Private Root Categories
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])
    if @category.allowed_to_read #Show only if the user is allowed to see it
      respond_to do |format|
        format.html # show.html.erb
        format.rss #show.rss.erb
        format.xml  { render :xml => @category }
      end
    else
      flash[:notice] = 'You are not authorized to view this Category.'
      redirect_back
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new
    @category.background = Background.new
    #If there is a category, set that as the default parent
    if(!params[:parent_id].blank?)
      @category.parent_id = params[:parent_id]	
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end
  
  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
    if @category.background.nil?
      @category.background = Background.new
    end
    if !@category.allowed_to_save
      flash[:notice] = 'Sorry, you do not have access to edit this category'
      redirect_back
    end
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])
    @parent = Category.find(@category.parent_id) unless @category.parent_id.blank? 
    #I had to draw a Karnaugh map to figure this out.
    if !admin_logged_in? && @category.parent_id.blank?
      flash[:notice] = "Only a system admins can create a root category."
      redirect_back
    elsif !@parent.nil? && !@parent.allowed_to_save
      flash[:notice] = "Sorry, you do not have access to create a new category here."
      redirect_back
    else
      respond_to do |format|
        if @category.save
          flash[:notice] = 'Category was successfully created.'
          format.html { redirect_to(@category) }
          format.xml  { render :xml => @category, :status => :created, :location => @category }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])
    if params[:category].has_key?("background_attributes") && params[:category][:background_attributes].has_key?("id")
      params[:category][:background_attributes].delete("id")
    end
      
    logger.debug params.to_yaml
    #only users who own this category can change it. Super Admins can change it too.
    if @category.allowed_to_save
      respond_to do |format|
        if @category.update_attributes(params[:category])
          flash[:notice] = 'Category was successfully updated.'
          format.html { redirect_to(@category) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
        end
      end
    else
      flash[:notice] = 'Permission denied.'
      redirect_back
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    if @category.allowed_to_save
      @category.destroy
      flash[:notice] = 'Category was successfully deleted.'
      respond_to do |format|
        format.html { redirect_to(categories_url) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = 'Permission denied.'
      redirect_back
    end
  end
end
