class FileAttachmentsController < ApplicationController
  filter_resource_access :collection => {:index => :browse}

  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name_type, :file_attachment, :file_attachment_cache]
      permitted_attributes << :owner_id if permitted_to? :transfer, @file_attachment
      permitted_attributes << :name if params.require(:file_attachment)[:name_type] == 'other'
      params.require(:file_attachment).permit(*permitted_attributes)
    end
  end

  def new_file_attachment_from_params
    @file_attachment = FileAttachment.new(:owner => current_user)
  end

  # GET /file_attachments
  def index
    case params[:filter].to_s
    when 'my'
      permitted_to! :manage, FileAttachment.new(:owner_id => current_user.id)
      @file_attachments = FileAttachment.where(:owner_id => current_user.id)
    else
      permitted_to! :manage, FileAttachment.new
      @file_attachments = FileAttachment.scoped
    end
  end

  # GET /file_attachments/1
  def show
  end

  # GET /file_attachments/1/download
  def download
    send_file FileAttachmentUploader.root + @file_attachment.file_attachment_url, :filename => @file_attachment.filename, :disposition => 'inline'
  end

  # GET /file_attachments/new
  def new
  end

  # GET /file_attachments/1/edit
  def edit
  end

  # POST /file_attachments
  def create
    respond_to do |format|
      if @file_attachment.update_attributes(permitted_params)
        format.html { redirect_to(@file_attachment, :notice => 'File attachment was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /file_attachments/1
  def update
    respond_to do |format|
      if @file_attachment.update_attributes(permitted_params)
        format.html { redirect_to(@file_attachment, :notice => 'File attachment was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /file_attachments/1
  def destroy
    @file_attachment.destroy

    respond_to do |format|
      format.html { redirect_to(file_attachments_url) }
      format.xml  { head :ok }
    end
  end

end
