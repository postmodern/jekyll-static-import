# jekyll-import

* [Homepage](https://github.com/postmodern/jekyll-import#readme)
* [Issues](https://github.com/postmodern/jekyll-import/issues)
* [Documentation](http://rubydoc.info/gems/jekyll-import/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

Spiders a website, extracts the content, and converts the HTML into Markdown,
for [Jekyll].

## Features

* Spiders entire websites.
* Sanitizes HTML.
* Converts HTML into Markdown.
* Generates [Jekyll] pages.

## Examples

    require 'jekyll/import'

## Synopsis

    $ jekyll-import http://www.example.com/ -o www.example.com/

## Requirements

* [kramdown] ~> 0.14
* [spidr] ~> 0.4

## Install

    $ gem install jekyll-import

## Copyright

Copyright (c) 2013 Postmodern

See {file:LICENSE.txt} for details.

[kramdown]: http://kramdown.rubyforge.org/
[spidr]: https://github.com/postmodern/spidr#readme

[Jekyll]: http://jekyllrb.com/
