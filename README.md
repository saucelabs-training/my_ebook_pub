# MyEbookPub

TODO: Write a gem description

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


```ruby
# content numbered (e.g., 1.md, 10.md, etc.)
# content lives in ./content/chapters (unless otherwise specified)
# cover.md in ./assets dir
# font file in ./assets dir (e.g., droid_sans.ttf)
# preface.md alongside other markdown files
# create output dir

MyEbookPub.generate(
  product_name: '',
  location: '', # if other than ./content/chapters
  file_type: 'html') # Optional. If not specified, PDF will be used
)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/my_ebook_pub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
