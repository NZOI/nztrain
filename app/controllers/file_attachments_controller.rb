class FileAttachmentsController < ApplicationController
  def permitted_params
    permitted_attributes = [:name_type, :file_attachment, :file_attachment_cache]
    permitted_attributes << :owner_id if policy(@file_attachment || FileAttachment).transfer?
    permitted_attributes << :name if params.require(:file_attachment)[:name_type] == "other"
    params.require(:file_attachment).permit(*permitted_attributes)
  end

  def index
    case params[:filter].to_s
    when "my"
      authorize FileAttachment.new(owner_id: current_user.id), :manage?
      @file_attachments = FileAttachment.where(owner_id: current_user.id)
    else
      authorize FileAttachment.new, :manage?
      @file_attachments = FileAttachment.all
    end
  end

  def show
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :show?
  end

  def download
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :download?
    send_file FileAttachmentUploader.root + @file_attachment.file_attachment_url, filename: @file_attachment.filename, disposition: "inline"
  end

  def new
    @file_attachment = FileAttachment.new(owner: current_user)
    authorize @file_attachment, :new?
  end

  def edit
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :edit?
  end

  def create
    @file_attachment = FileAttachment.new(permitted_params)
    @file_attachment.owner ||= current_user
    authorize @file_attachment, :create?

    if @file_attachment.save
      redirect_to(@file_attachment, notice: "File attachment was successfully created.")
    else
      render action: "new"
    end
  end

  def update
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :update?

    if @file_attachment.update_attributes(permitted_params)
      redirect_to(@file_attachment, notice: "File attachment was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @file_attachment = FileAttachment.find(params[:id])
    authorize @file_attachment, :destroy?
    @file_attachment.destroy

    redirect_to(file_attachments_url)
  end
end
