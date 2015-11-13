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
  pub generate
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

### Generate

```sh
> pub generate
Generating PDF to output directory...
Your file is ready. See ./output/render.pdf
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/my_ebook_pub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
