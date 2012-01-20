module ApplicationHelper
  # TODO FIXME escape_javascript override
  # https://github.com/rails/rails/pull/1558
  # REMOVE THIS MONKEY PATCH WHEN RAILS UPGRADED
  JS_ESCAPE_MAP	=	{ '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n', "\r" => '\n', '"' => '\\"', "'" => "\\'" } 
  def escape_javascript(javascript)
    if javascript
      javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { |s| JS_ESCAPE_MAP[s] }
    else
      ''
    end 
  end
end
