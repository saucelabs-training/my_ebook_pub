# MyEbookPub

Convert content written in markdown into a polished PDF

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'my_ebook_pub'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install my_ebook_pub

## Usage

```sh
> pub
Usage:
  pub new
  pub generate filetype

  options:
    If no filetype specified, pdf will be used
    Available file types: pdf, epub, mobi
```

### New

```sh
> pub new
Creating new pub directory structure...
assets
assets/droid_sans.ttf
assets/template.erb
content
content/chapters
content/chapters/1.md
content/cover.md
content/preface.md
output
Your project is ready for content!
```

### Writing Content

Content files:
- live in `content/chapters`
- can be named with alpha-numeric characters
- are ordered alphabetically

Table of Contents:
- are auto-generated with active links
- are numbered based on the order of files in `content/chapters`

Preface & Cover
- live in `content`
- are auto-included with the book rendering

Assets
- contain the font and styling used for the book
- can store images to be used in the book (e.g., art for the cover of the book)

### Generate

```sh
> pub generate
Generating PDF to output directory...
Your file is ready. See ./output/render.pdf

> pub generate epub
Generating PDF to output directory...
Your file is ready. See ./output/render.epub

> pub generate mobi
Generating PDF to output directory...
Your file is ready. See ./output/render.mobi
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/my_ebook_pub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
