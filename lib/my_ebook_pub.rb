require "my_ebook_pub/version"
require 'redcarpet'
require 'redcarpet/render_strip'
require 'erb'
require 'pygments'
require 'docverter'

module MyEbookPub

  extend self

@template = <<HERE
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title>The Selenium Guidebook: How To Use Selenium, successfully</title>
    <style type="text/css">
      @font-face {
        font-family: 'Droid Sans';
        font-style: normal;
        font-weight: 400;
        src: url('droid_sans.ttf');
        -fs-pdf-font-embed: embed;
        -fs-pdf-font-encoding: Identity-H;
      }
      body {
        font-family: 'Droid Sans';
      }
      div.page_footer {
      }
      h1 {
        page-break-before: always;
      }
      pre {
        white-space: pre;
        white-space: pre-wrap;
        page-break-inside: avoid;
        orphans: 0;
        widows: 0;
        background-color: #f5f5f5;
        border: 1px solid #ccc;
        border: 1px solid rgba(0, 0, 0, 0.15);
        border-radius: 4px;
        display: block;
        padding: 9.5px;
        margin: 0 0 10px;
        font-size: 13px;
        line-height: 20px;
      }
      code {
          padding: 2px 4px;
          background-color: #f7f7f9;
      }
      img {
        width: 600px;
      }
      table {
        page-break-inside: avoid;
        orphans: 0;
        widows: 0;
        font-size: 12px;
        border-collapse:collapse;
        margin:20px 0 0;
        padding:0;
      }
      table tr {
        border-top:1px solid #ccc;
        background-color:#fff;
        margin:0;
        padding:0;
      }
      table tr:nth-child(2n) {
        background-color:#f8f8f8;
      }
      table tr th[align="center"], table tr td[align="center"] {
        text-align:center;
      }
      table tr th, table tr td {
        border:1px solid #ccc;
        text-align:left;
        margin:0;
        padding:6px 13px;
      }
      <%= Pygments.css %>
    </style>
  </head>
  <body>
    <%= @content %>
  </body>
</html>
HERE

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
    case opts[:file_type]
    when 'html'
      `rm -rf output/html`
      `mkdir output/html`
      File.open("output/html/#{opts[:product_name]}.html", 'w+') { |f| f.write html }
      `cp assets/* output/html` 
    else
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

end
