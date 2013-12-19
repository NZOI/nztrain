class Problems::FilesController < Filelinks::RootsController
  layout 'problem'

  protected
  def root_class
    Problem
  end
end
