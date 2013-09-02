class MarkdownFormatter
  EXTENSIONS = {
    no_intra_emphasis: true,
    tables: true,
    fenced_code_blocks: true,
    autolink: false,
    disable_indented_code_blocks: false,
    strikethrough: true,
    lax_spacing: false,
    space_after_headers: true,
    superscript: true,
    underline: false,
    hightlight: false,
    quote: false,
    footnotes: false
  }

  class << self
    def render(text)
      processed_text = markdown_formatter.render(text)
      video_hack_render(processed_text)
    end

    private
    def markdown_formatter
      @markdown_formatter ||= Redcarpet::Markdown.new(render_engine, EXTENSIONS)
    end

    def render_engine
      @render_engine ||= RenderEngine.new(RenderEngine::RENDER_OPTIONS)
    end

    def video_hack_render(text)
      text.gsub(Waterflowseast::Regex.video) do |match|
        next "" if $1.blank?

        <<-FLEX_VIDEO
</p>
<div class="flex-video">
  <iframe width="420" height="315" src="#{$1}" frameborder="0" allowfullscreen>
  </iframe>
</div>
<p>
        FLEX_VIDEO
      end
    end
  end

  class RenderEngine < Redcarpet::Render::HTML
    RENDER_OPTIONS = {
      filter_html: true,
      no_images: false,
      no_links: false,
      safe_links_only: true,
      hard_wrap: false
    }

    def block_code(code, language)
      lexer = self.class.parse_language(language)
      highlight_code = Pygments.highlight(code, lexer: lexer, options: { lineanchors: 'line' })

      <<-CODE_BLOCK
<div class="code_block">
  <div class="code_header">
    #{language.nil? ? "text" : language} => #{lexer}
  </div>
  #{highlight_code}
</div>
      CODE_BLOCK
    end

    def self.parse_language(language)
      language = language && language.scan(/[a-z][\w#+-]*$/i).first.try(:downcase)
      return "text" if language.nil?

      lexer = Pygments.find_lexer(language)
      return "text" if lexer.nil?

      lexer.aliases.first
    end
  end
end