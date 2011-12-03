module ProblemsHelper
  def markdown_parse(str, options={})
    bc = BlueCloth.new(str, options)
    raw bc.to_html
  end
end
