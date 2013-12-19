class Groups::FilesController < Filelinks::RootsController
  layout 'group'

  protected
  def root_class
    Group
  end
end

