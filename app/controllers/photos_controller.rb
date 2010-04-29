class PhotosController < ApplicationController
  def index
    @photos = Photo.paginate(:page => params[:page], :per_page => 60)
  end

  def show
    @photo = Photo.find(params[:id])
  end
end
