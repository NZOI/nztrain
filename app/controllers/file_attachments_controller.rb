class FileAttachmentsController < ApplicationController
  def permitted_params
    @_permitted_params ||= begin
      permitted_attributes = [:name_type, :file_attachment, :file_attachment_cache]
      permitted_attributes << :owner_id if policy(@file_attachment || FileAttachment).transfer?
      permitted_attributes << :name if params.require(:file_attachment)[:name_type] == 'other'
      params.require(:file_attachment).permit(*permitted_attributes)
    end
  end

  # GET /file_attachments
  def index
    case params[:filter].to_s
    when 'my'
      authorize FileAttachment.new(:owner_id => current_user.id), :manage?
      @file_attachments = FileAttachment.where(:owner_id => current_user.id)
    else
      authorize FileAttachment.new, :manage?
      @file_attachments = FileAttachment.all
    end
  end

  # GET /file_attachments/1
  def show
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :show?
  end

  # GET /file_attachments/1/download
  def download
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :download?
    send_file FileAttachmentUploader.root + @file_attachment.file_attachment_url, :filename => @file_attachment.filename, :disposition => 'inline'
  end

  # GET /file_attachments/new
  def new
    @file_attachment = FileAttachment.new(:owner => current_user)
    authorize @file_attachment, :new?
  end

  # GET /file_attachments/1/edit
  def edit
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :edit?
  end

  # POST /file_attachments
  def create
    @file_attachment = FileAttachment.new(permitted_params)
    @file_attachment.owner ||= current_user
    authorize @file_attachment, :create?
    respond_to do |format|
      if @file_attachment.save
        format.html { redirect_to(@file_attachment, :notice => 'File attachment was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /file_attachments/1
  def update
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :update?
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
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :destroy?
    @file_attachment.destroy

    respond_to do |format|
      format.html { redirect_to(file_attachments_url) }
      format.xml  { head :ok }
    end
  end

end
