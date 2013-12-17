class Groups::FilesController < ApplicationController
  layout 'group'

  private
  def group_file_attachment_params
    @group_file_attachment_params ||= [:filepath, :file_attachment_id]
    params.require(:group_file_attachment).permit(*@group_file_attachment_params)
  end

  public
  def index
    @group = Group.find(params[:group_id])
    authorize @group, :access?
    @files = @group.group_file_attachments.order(:filepath)
    @new_file = GroupFileAttachment.new
  end

  def show
    @group = Group.find(params[:group_id])
    authorize @group, :access?
    @file = @group.group_file_attachments.find(params[:id])
    send_file FileAttachmentUploader.root + @file.file_attachment_url, :filename => File.basename(@file.filepath), :disposition => 'inline'
  end

  def update
    @group = Group.find(params[:group_id])
    authorize @group, :update?
    @file = @group.group_file_attachments.find(params[:id])
    if @file.update_attributes(group_file_attachment_params)
      redirect_to(group_files_path(@group), :notice => "File attachment updated")
    else
      redirect_to(group_files_path(@group), :notice => "File attachment not updated")
    end
  end

  def create
    @group = Group.find(params[:group_id])
    authorize @group, :update?
    @new_file = @group.group_file_attachments.build(group_file_attachment_params)
    if @new_file.save
      redirect_to(group_files_path(@group), :notice => "File attachment added")
    else
      @files = @group.group_file_attachments.order(:filepath)
      render :action => :index
    end
  end

  def destroy
    @group = Group.find(params[:group_id])
    authorize @group, :update?
    @file = @group.group_file_attachments.find(params[:id])
    if @group.group_file_attachments.destroy(@file)
      redirect_to(group_files_path(@group), :notice => "File attachment removed")
    else
      redirect_to(group_files_path(@group), :notice => "File attachment not removed")
    end
  end
end

