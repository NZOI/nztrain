module ProblemsHelper
  @markdown_renderer = Redcarpet::Markdown.new(
    Redcarpet::Render::HTML.new(no_styles: true, safe_links_only: true, with_toc_data: true),
    no_intra_emphasis: true, # foo_bar_baz will not generate <em> tags
    tables: true, # parse tables, PHP-Markdown style
    fenced_code_blocks: true, # parse fenced code blocks, PHP-Markdown style.
    #   Blocks delimited with 3 or more ~ or backticks will be considered as code,
    #   without the need to be indented. An optional language name may be added.
    autolink: true, # parse links even when not enclosed in <> characters
    # :disable_indented_code_blocks => false, # do not parse indented text (4 spaces) as code blocks
    strikethrough: true, # parse ~~strikethrough~~, PHP-Markdown style
    lax_spacing: true, # HTML blocks do not require to be surrounded by an empty line as in the Markdown standard.
    space_after_headers: true, # `# header` is valid, `#header` is not
    # :superscript => false,                  # parse superscripts after the ^ character
    #   contiguous superscripts are nested, and complex values can be enclosed in parenthesis
    #   e.g. this is the 2^(nd) time.
    underline: true, # parse underscored emphasis as underlines. This is _underlined_ but this is still *italic*.
    highlight: true, # parse highlights. This is ==highlighted==. It looks like this: <mark>highlighted</mark>
    quote: true, # parse quotes. This is a "quote". It looks like this: <q>quote</q>
    footnotes: true # parse footnotes, PHP-Markdown style.
    #   A footnote works very much like a reference-style link:
    #   it consists of a marker next to the text (e.g. This is a sentence.[^1])
    #   and a footnote definition on its own line anywhere within the document
    #   (e.g. [^1]: This is a footnote.).
  )

  def self.markdown_renderer
    @markdown_renderer
  end

  def markdown_parse(str, relative_root: request.path + "/")
    content = ProblemsHelper.markdown_renderer.render(str || "")
    content = Loofah.fragment(content)
      .scrub!(Loofah::Scrubbers::NoComment.new) # remove comments
      .scrub!(Loofah::Scrubbers::EscapeWithCustomWhitelist.new) # remove dangerous tags
      .scrub!(Loofah::Scrubbers::NoForm.new) # remove forms
      .scrub!(Loofah::Scrubbers::MathJax.new) # add mathjax support
    unless relative_root.nil?
      content = content.scrub!(Loofah::Scrubbers::RelativeLink.new(relative_root)) # re-write relative links as rooted links
    end
    content.to_s.html_safe
  end

  def test_status(problem)
    colour = case problem.test_status
             when -1 then "#FF0000"
             when -2 then "#FF8000"
             when 0 then "#808080"
             when 1 then "#FFFF00"
             when 2 then "#80FF00"
             when 3 then "#00C000"
             else; "#808080"
    end

    content_tag :div, " ", style: "border-radius: 50%; width: 15px; height: 15px; background-color: #{colour}; display: inline-block"
  end
end
