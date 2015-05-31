require "my_ebook_pub/version"
require 'redcarpet'
require 'redcarpet/render_strip'
require 'erb'
require 'pygments'
require 'docverter'

module MyEbookPub

  extend self

  class HighlightedCopyWithChapterNumbering < Redcarpet::Render::HTML
    def header(text, header_level)
      if header_level == 1
        @counter ||= 0
        @counter += 1
        "<h1 id=\"chapter#{@counter}\"><small>Chapter #{@counter}</small><br>#{text}</h1>\n"
      else
        "<h#{header_level}>#{text}</h#{header_level}>\n"
      end
    end

    def block_code(code, language)
      Pygments.highlight(code, lexer: language, encoding: 'utf-8')
    end

    def postprocess(document)
      document.gsub('&#39;', "'")
    end
  end

  class CopyWithNoFrills < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, :lexer => language)
    end

    def postprocess(document)
      document.gsub('&#39;', "'")
    end
  end

  class TOCwithChapterNumbering < Redcarpet::Render::StripDown
    attr_reader :chapters

    def header(text, header_level)
      return unless header_level == 1
      @chapters ||= []
      @chapters << text
      ""
    end

    def postprocess(document)
      items = []
      @chapters.each_with_index do |text, chapter_number|
        items << "<li><a href=\"#chapter#{chapter_number+1}\">#{text}</a></li>"
      end
return <<HERE
  <ol>
  #{items.join("\n")}
  </ol>
HERE
    end

  end

  @renderer_toc         = Redcarpet::Markdown.new(TOCwithChapterNumbering, fenced_code_blocks: true)
  @renderer_content     = Redcarpet::Markdown.new(HighlightedCopyWithChapterNumbering, fenced_code_blocks: true)
  @renderer_no_frills   = Redcarpet::Markdown.new(CopyWithNoFrills, fenced_code_blocks: true)

  def vacuum
    tmp = ""
    tmp << yield
    tmp << "\n\n"
    tmp
  end

  def cover
    @renderer_no_frills.render( vacuum { File.read("#{@location}/cover.md") })
  end

  def acknowledgements
    @renderer_no_frills.render( vacuum { File.read("#{@location}/acknowledgements.md") })
  end

  def preface
    @renderer_no_frills.render( vacuum { File.read("#{@location}/preface.md") })
  end

  def toc
    '<h1>Table of Contents</h1>' + @renderer_toc.render(raw_content)
  end

  def raw_content
    content = ""
    number_of_chapters.times do |chapter|
      content << File.read("#{@location}/#{chapter + 1}.md")
    end
    content
  end

  def number_of_chapters
    Dir.glob("#{@location}/[0-9].md").count + Dir.glob("#{@location}/[0-9][0-9].md").count
  end

  def content
    @renderer_content.render(raw_content)
  end

  def generate(opts = {}) # to PDF
    @location = opts[:location].nil? ? 'content/chapters' : opts[:location]
    @content = preface + toc + content
    html = ERB.new(@template).result(binding)
    product_name = opts[:product_name].nil? ? raise('Product name not specified. Please specify one.') : opts[:product_name]
    File.open("output/#{product_name}.pdf", 'w+') do |f|
      f.write(Docverter::Conversion.run do |c|
        c.from    = 'html'
        c.to      = 'pdf'
        c.content = html
        Dir.glob('assets/*') do |asset|
          c.add_other_file asset
        end
      end)
    end
  end

end
