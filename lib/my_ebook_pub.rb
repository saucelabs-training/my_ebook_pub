require "my_ebook_pub/version"
require 'redcarpet'
require 'redcarpet/render_strip'
require 'erb'
require 'pygments'
require 'docverter'

module MyEbookPub

  extend self

  @template = File.read('assets/template.erb')

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
  @renderer_content     = Redcarpet::Markdown.new(HighlightedCopyWithChapterNumbering, fenced_code_blocks: true, tables: true)
  @renderer_no_frills   = Redcarpet::Markdown.new(CopyWithNoFrills, fenced_code_blocks: true)

  def vacuum
    tmp = ""
    tmp << yield
    tmp << "\n\n"
    tmp
  end

  def cover
    @renderer_no_frills.render(vacuum { File.read("#{@location}/cover.md") })
  end

  def acknowledgements
    @renderer_no_frills.render(vacuum { File.read("#{@location}/acknowledgements.md") })
  end

  def preface
    @renderer_no_frills.render(vacuum { File.read("#{@location}/preface.md") })
  end

  def toc
    '<h1>Table of Contents</h1>' + @renderer_toc.render(raw_content)
  end

  def raw_content
    content = ""
    Dir.glob("#{@location}/chapters/*.md").each do |chapter|
      content << File.read(chapter)
    end
    content
  end

  def content
    @renderer_content.render(raw_content)
  end

  def generate(file_type)
    @location = 'content'
    @content = cover + preface + acknowledgements + toc + content
    html = ERB.new(@template).result(binding)
    product_name = 'draft'

    case file_type
    when 'html'
      File.open("output/#{product_name}.html", 'w+') do |file|
        file.write(html)
      end
    when 'pdf'
      File.open("output/#{product_name}.pdf", 'w+') do |file|
        file.write(Docverter::Conversion.run do |c|
          c.from    = 'html'
          c.to      = 'pdf'
          c.content = html
          Dir.glob('assets/*') do |asset|
            c.add_other_file asset
          end
        end)
      end
    when 'epub'
      File.open("output/#{product_name}.epub", 'w+') do |file|
        file.write(Docverter::Conversion.run do |c|
          c.from              = 'markdown'
          c.to                = 'epub'
          c.content           = raw_content
          c.epub_metadata     = 'metadata.xml'
          c.epub_stylesheet   = 'epub.css'
          c.add_other_file    'assets/epub.css'
          c.add_other_file    'assets/metadata.xml'
        end)
      end
    when 'mobi'
      File.open("output/#{product_name}.mobi", 'w+') do |file|
        file.write(Docverter::Conversion.run do |c|
          c.from              = 'markdown'
          c.to                = 'mobi'
          c.content           = raw_content
          c.epub_metadata     = 'metadata.xml'
          c.epub_stylesheet   = 'epub.css'
          c.add_other_file    'assets/epub.css'
          c.add_other_file    'assets/metadata.xml'
        end)
      end
    end

  end

end
