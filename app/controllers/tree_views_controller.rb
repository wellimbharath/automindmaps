require 'open-uri'
class TreeViewsController < ApplicationController
  before_action :set_tree_view, only: [:show, :edit, :update, :destroy]

  # GET /tree_views
  # GET /tree_views.json
  def index
    @tree_views = TreeView.all
  end

  # GET /tree_views/1
  # GET /tree_views/1.json
  def show
    path = File.join Rails.root, 'public', 'system', 'json_files', '000', '000', "00#{@tree_view.id}", 'original'
    FileUtils.mkdir_p(path) unless File.exist?(path)
    File.open("#{path}/tree.json","w+") unless File.exist?("#{path}/tree.json")
    if @tree_view.file.present?
        @tree = TreeMap.new(path,root_url+@tree_view.file.url,@tree_view.id)
    else
      @tree = TreeMap.new(path,@tree_view.link,@tree_view.id)
    end
  end

  # GET /tree_views/new
  def new
    @tree_view = TreeView.new
  end

  # GET /tree_views/1/edit
  def edit
  end

  # POST /tree_views
  # POST /tree_views.json
  def create
    @tree_view = TreeView.new(tree_view_params)
    respond_to do |format|
      if @tree_view.save
        format.html { redirect_to @tree_view, notice: 'Tree view was successfully created.' }
        format.json { render :show, status: :created, location: @tree_view }
      else
        format.html { render :new }
        format.json { render json: @tree_view.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tree_views/1
  # PATCH/PUT /tree_views/1.json
  def update
    respond_to do |format|
      if @tree_view.update(tree_view_params)
        format.html { redirect_to @tree_view, notice: 'Tree view was successfully updated.' }
        format.json { render :show, status: :ok, location: @tree_view }
      else
        format.html { render :edit }
        format.json { render json: @tree_view.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tree_views/1
  # DELETE /tree_views/1.json
  def destroy
    @tree_view.destroy
    respond_to do |format|
      format.html { redirect_to tree_views_url, notice: 'Tree view was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tree_view
      @tree_view = TreeView.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tree_view_params
      params.require(:tree_view).permit(:link, :file)
    end
end
