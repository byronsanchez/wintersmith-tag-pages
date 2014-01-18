path = require 'path'
wintersmith = require 'wintersmith'
chai = require 'chai'
expect = chai.expect
wsTagPages = require './../src'

env = null
loadedData = null
articles = null
TagPage = null
tags = null
pages = null
rv = null

describe "wintersmith-tag-pages", ->

  # retrieve all tags and generate data.
  beforeEach (done) ->
    env = null
    loadedDate = null
    articles = null
    TagPage = null
    tags = null
    pages = null
    rv = null

    testDir = __dirname
    contentsDir = path.join(testDir, "contents")
    templatesDir = path.join(testDir, "templates")
    outputDir = path.join(testDir, "build")
    Config = require('./config.json')
    Config.contents = contentsDir
    Config.templates = templatesDir
    Config.output = outputDir
    env = wintersmith Config
    env.workDir = testDir
    expect(env).to.be.an.instanceOf(wintersmith.Environment)
    env.load((err, result) ->
      loadedData = result
      expect(loadedData.contents).to.be.an.instanceOf(wintersmith.ContentTree)
      articles = loadedData.contents['articles']._.directories.map (item) -> item.index
      articles.sort (a, b) -> b.date - a.date
      expect(articles).to.be.an('array')
      TagPage = env.helpers.TagPage
      options = {}
      options.template = ""
      options.first = ""
      options.filename = ""
      options.filter = []
      options.perPage = 1
      tags = TagPage.retrieveListOfAllTagsUsedByArticles(articles, options)
      pages = TagPage.createObjectContainingAllTagPages(tags, articles, options)
      rv = TagPage.createObjectToBeMergedWithContentTree(tags, pages)
      done()
    )

  it "should retrieve a list of all tags used across all articles", (done) ->
    expectedTags = ['here', 'are', 'some', 'new', 'tags']
    expect(tags).to.have.members(expectedTags)
    expect(tags).to.have.length(expectedTags.length)
    done()

  it "should not have duplicate tags in the list", (done) ->
    # check for duplicate tags in the list; there should be no dupes
    # returned by the method
    sortedTags = tags.sort()
    doDuplicateTagsExistInTheList = false
    last = ""
    for tag in sortedTags
      if tag == last
        doDuplicateTagsExistInTheList = true
        break
    expect(doDuplicateTagsExistInTheList).to.equal(false)

    done()

  it "should create a page for each tag", (done) ->
    # check for expected tag pages
    expect(pages.here).to.exist
    expect(pages.are).to.exist
    expect(pages.some).to.exist
    expect(pages.tags).to.exist
    expect(pages.new).to.exist

    done()

  it "should paginate tag pages", (done) ->
    # ensure proper pagination
    expect(pages.here).to.have.length(2)
    expect(pages.are).to.have.length(1)
    expect(pages.some).to.have.length(1)
    expect(pages.tags).to.have.length(2)
    expect(pages.new).to.have.length(1)

    # check for expected prev/next pages
    expect(pages.here[0].prevPage).to.not.exist
    expect(pages.here[0].nextPage).to.equal(pages.here[1])
    expect(pages.here[1].prevPage).to.equal(pages.here[0])
    expect(pages.here[1].nextPage).to.not.exist
    expect(pages.are[0].prevPage).to.not.exist
    expect(pages.are[0].nextPage).to.not.exist
    expect(pages.some[0].prevPage).to.not.exist
    expect(pages.some[0].nextPage).to.not.exist
    expect(pages.tags[0].prevPage).to.not.exist
    expect(pages.tags[0].nextPage).to.equal(pages.tags[1])
    expect(pages.tags[1].prevPage).to.equal(pages.tags[0])
    expect(pages.tags[1].nextPage).to.not.exist
    expect(pages.new[0].prevPage).to.not.exist
    expect(pages.new[0].nextPage).to.not.exist

    # check for expected articles
    expect(pages.here[0].articles).to.exist
    expect(pages.here[1].articles).to.exist
    expect(pages.are[0].articles).to.exist
    expect(pages.some[0].articles).to.exist
    expect(pages.tags[0].articles).to.exist
    expect(pages.tags[1].articles).to.exist
    expect(pages.new[0].articles).to.exist

    done()

  it "should create object to be merged with content tree", (done) ->
    # Page for each tag and for each pagination for that tag. 5 tags are being
    # tested. 2 tags are shared by articles. The configuration of the pagination
    # is 1 article per page. So 5 + 2 = 7
    expect(Object.keys(rv.tags)).to.have.length(7)
    expect(rv.tags['here-1.page']).to.exist
    expect(rv.tags['here-2.page']).to.exist
    expect(rv.tags['are-1.page']).to.exist
    expect(rv.tags['some-1.page']).to.exist
    expect(rv.tags['tags-1.page']).to.exist
    expect(rv.tags['tags-2.page']).to.exist
    expect(rv.tags['new-1.page']).to.exist
   
    # check for expected tag pages
    # check for expected default index
    done()

