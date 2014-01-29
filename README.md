# wintersmith-tag-pages

[![Build Status](https://secure.travis-ci.org/byronsanchez/wintersmith-tag-pages.png?branch=develop)][travis]

[travis]: https://travis-ci.org/byronsanchez/wintersmith-tag-pages

wintersmith-tag-pages is a plugin that generates tag page indexes for either:

  - every tag used in every article
  - a set of specified tags defined in `config.json`

## Requirements

This repo is meant to be used as a plugin for 
[Wintersmith](https://github.com/jnordberg/wintersmith)-generated websites. To 
use this plugin, simply setup a wintersmith website and follow the setup 
instructions below.

## Setup

Setting up the plugin is very simple:

    npm install wintersmith-tag-pages

Alternatively, you can define the plugin as a dependency in your `package.json` file and run:

    npm install

In your `config.json` file, you must define the location of the plugin:

    "plugins": [
      "./node_modules/wintersmith-tag-pages/"
    ]

## Configuration

You may configure how the tag page generators creates the tag index pages.  
Simply add a `tagPages` configuration object hash in `config.json`:

    "tagPages": {
      "perPage": 2
    }

### Options

The following is a list of all available options. You can define these in the 
`tagPages` configuration object hash.

Name         | Default                | Description
-------------|------------------------|-----------------------------------------------
template     | `tags.jade`            | template file to generate the tag pages
first        | `tag/%t/index.html`    | permalink for the first page in each tag index
filename     | `tag/%t/%d/index.html` | permalink for every subsequent tag page 
filter       | `[]`                   | array of tags to generate pages for; if empty, pages for all tags will be generated
perPage      | `2`                    | number of articles to display for each tag page

- %t - The tag name
- %d - The page number

## Usage

Once you have completed the setup and configuration, the plugin will be invoked 
during each wintersmith build.

Be sure to create a template file that can be used to render the tag pages. By 
default, the plugin will look for a file called `tags.jade`, but you can 
override this setting using the configuration options described above.

The specified template will have access to the following data:

  - prevPage - The article object of the previous page in a tag's index.
  - nextPage - The article object of the next page in a tag's index.
  - tag - The name of the tag whose index is being rendered.
  - articles - The list of articles for the current tag page.

Use this data to help build the template used to generate your tag pages. Don't 
forget to check whether or not `prevPage` and `nextPage` exists.

## License

"wintersmith-tag-pages" is Copyright (c) 2014 by Byron Sanchez, licensed under
the GNU GPL v2.0.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, version 2 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.


