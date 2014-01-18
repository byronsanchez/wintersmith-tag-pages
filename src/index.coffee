
module.exports = (env, callback) ->

  defaults =
    template: 'tags.jade' # template that renders pages
    first: 'tag/%t/index.html' # filename for first page
    filename: 'tag/%t/%d/index.html' # filename for rest of pages
    filter: [ # tags to create pages for. If empty, will create for all.
    ]
    perPage: 2 # number of articles per page

  options = env.config.tagPages or {}
  for key, value of defaults
    options[key] ?= defaults[key]

  class TagPage extends env.plugins.Page

    # tag - The raw tag string retrieved from the article's metadata
    # formatted-tag - A handleized version of the tag, to be used in urls
    # articles - the articles to render for one of the tag pages
    # pageNum - the number of this particular tag page
    constructor: (@tag, @formatted_tag, @articles, @pageNum) ->

    getFilename: ->
      if @pageNum is 1
        options.first.replace '%t', @formatted_tag
      else
        filename = options.filename.replace '%t', @formatted_tag
        filename.replace '%d', @pageNum

    getView: -> (env, locals, contents, templates, callback) ->
      template = templates[options.template]
      if not template?
        return callback new Error "unknown tags template '#{ options.template }'"

      if @articles
        ctx = {@articles, @tag, @prevPage, @nextPage}
      else
        ctx = {@tag, @prevPage, @nextPage}

      env.utils.extend ctx, locals

      template.render ctx, callback

    @retrieveListOfAllTagsUsedByArticles = (articles, options) ->
      tags = options.filter or []
      # Get a list of all tags if there are none defined through the filter
      if !tags || tags.length < 1
        for article in articles
          if article.metadata.tags
            for tag in article.metadata.tags
              if !(tags.indexOf(tag) > -1)
                tags.push tag

      return tags

    @createObjectContainingAllTagPages = (tags, articles, options) ->
      pages = {}
      for tag in tags
        pages[tag] = []
        articles_with_tag = []

        # build an array of articles containing the current iteration's tag
        for article in articles
          article_tags = article.metadata.tags
          if article_tags.indexOf(tag) > -1
            articles_with_tag.push article

        # populate pages
        numPages = Math.ceil articles_with_tag.length / options.perPage
        for i in [0...numPages]
          tag_articles = articles_with_tag.slice i * options.perPage, (i + 1) * options.perPage
          handleizedTag = tag.toLowerCase().trim().replace(/\s/g, '-').replace(/[^\w-]/g, '')
          pages[tag].push(new TagPage tag, handleizedTag, tag_articles, i + 1)

        # add references to prev/next to each page
        for page, i in pages[tag]
          page.prevPage = pages[tag][i - 1]
          page.nextPage = pages[tag][i + 1]

      return pages

    @createObjectToBeMergedWithContentTree = (tags, pages) ->
      rv = {tags:{}}
      for tag in tags
        # If there are no articles available for the tag, create a default page
        # for the tag so potential links don't break.
        if !pages[tag] || pages[tag].length < 1
          handleizedTag = tag.toLowerCase().trim().replace(/\s/g, '-').replace(/[^\w-]/g, '')
          rv.tags["#{ tag }"] = new TagPage tag, handleizedTag, null, 1
        # Else pass the content index to the page
        else
          for page in pages[tag]
            rv.tags["#{ page.tag + '-' + page.pageNum }.page"] = page

      return rv

  env.registerGenerator 'tags', (contents, callback) ->
    articles = contents['articles']._.directories.map (item) -> item.index
    articles.sort (a, b) -> b.date - a.date
    tags = TagPage.retrieveListOfAllTagsUsedByArticles(articles, options)
    pages = TagPage.createObjectContainingAllTagPages(tags, articles, options)
    rv = TagPage.createObjectToBeMergedWithContentTree(tags, pages)

    # callback with the generated contents
    callback null, rv

  env.helpers.TagPage = TagPage

  # tell the plugin manager we are done
  callback()

