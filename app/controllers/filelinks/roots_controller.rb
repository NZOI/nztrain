class Filelinks::RootsController < ApplicationController
  private
  helper_method :model, :index_path, :show_path, :download_path

  def model
    instance_variable_get :"@#{root_name}"
  end

  def model=(model)
    instance_variable_set :"@#{root_name}", model
  end

  def root_name
    root_class.name.parameterize
  end

  def index_path
    send("#{root_name}_files_path", model)
  end

  def show_path(filelink)
    send("#{root_name}_file_path", model, filelink)
  end

  def download_path(filelink)
    send("download_#{root_name}_files_path", model, filelink.filepath)
  end

  def filelink_params
    @filelink_params ||= [:filepath, :file_attachment_id]
    params.require(:filelink).permit(*@filelink_params)
  end

  protected
  def load_model
    root_class.find(params[:"#{root_name}_id"])
  end

  def root_class
    Object
  end

  public
  def index
    self.model = load_model
    authorize model, :access?
    @filelinks = model.filelinks.order(:filepath)
    @new_filelink = Filelink.new
  end

  def show
    self.model = load_model
    authorize model, :access?
    if params[:id]
      @filelink = model.filelinks.find(params[:id])
    else
      filepath = [params[:filepath], params[:format]].compact.join('.')
      @filelink = model.filelinks.find_by_filepath(filepath)
    end
    send_file FileAttachmentUploader.root + @filelink.file_attachment_url, :filename => File.basename(@filelink.filepath), :disposition => 'inline'
  end

  def update
    self.model = load_model
    authorize model, :update?
    @filelink = model.filelinks.find(params[:id])
    attachment_id = filelink_params.fetch(:file_attachment_id, @filelink.file_attachment_id)
    authorize FileAttachment.find(attachment_id), :use? unless @filelink.file_attachment_id == attachment_id
    
    if @filelink.update_attributes(filelink_params)
      redirect_to(index_path, :notice => "File attachment updated")
    else
      redirect_to(index_path, :notice => "File attachment not updated")
    end
  end

  def create
    self.model = load_model
    authorize model, :update?
    authorize FileAttachment.find(filelink_params[:file_attachment_id]), :use?
    @new_file = model.filelinks.build(filelink_params)
    if @new_file.save
      redirect_to(index_path, :notice => "File attachment added")
    else
      @files = model.filelinks.order(:filepath)
      render :action => :index
    end
  end

  def destroy
    self.model = load_model
    authorize model, :update?
    @filelink = model.filelinks.find(params[:id])
    if model.filelinks.destroy(@filelink)
      redirect_to(index_path, :notice => "File attachment removed")
    else
      redirect_to(index_path, :notice => "File attachment not removed")
    end
  end
end

