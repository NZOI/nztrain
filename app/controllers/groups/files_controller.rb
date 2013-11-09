class Groups::FilesController < ApplicationController
  layout 'group'

  filter_resource_access context: :groups, attribute_check: true, collection: [], new: [],
                         member: {
                                    :index => :access_files,
                                    :show => :access_files,
                                    :update => :update,
                                    :create => :update,
                                    :destroy => :update
                                 }
  private
  def load_file
    @group = Group.find(params[:group_id])
  end

  def group_file_attachment_params
    @group_file_attachment_params ||= [:filepath, :file_attachment_id]
    params.require(:group_file_attachment).permit(*@group_file_attachment_params)
  end

  public
  def index
    @files = @group.group_file_attachments.order(:filepath)
    @new_file = GroupFileAttachment.new
  end

  def show
    @file = @group.group_file_attachments.find(params[:id])
    send_file FileAttachmentUploader.root + @file.file_attachment_url, :filename => File.basename(@file.filepath), :disposition => 'inline'
  end

  def update
    @file = @group.group_file_attachments.find(params[:id])
    if @file.update_attributes(group_file_attachment_params)
      redirect_to(group_files_path(@group), :notice => "File attachment updated")
    else
      redirect_to(group_files_path(@group), :notice => "File attachment not updated")
    end
  end

  def create
    @new_file = @group.group_file_attachments.build(group_file_attachment_params)
    if @new_file.save
      redirect_to(group_files_path(@group), :notice => "File attachment added")
    else
      @files = @group.group_file_attachments.order(:filepath)
      render :action => :index
    end
  end

  def destroy
    @file = @group.group_file_attachments.find(params[:id])
    if @group.group_file_attachments.destroy(@file)
      redirect_to(group_files_path(@group), :notice => "File attachment removed")
    else
      redirect_to(group_files_path(@group), :notice => "File attachment not removed")
    end
  end
end

