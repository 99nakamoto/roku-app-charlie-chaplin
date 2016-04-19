# If you are looking for Roku app tutorial

Read https://github.com/michaelran16/roku-app-charlie-chaplin

# Scrapy tutorial 

Using __scrapy_charlie_chaplin__ as an example. 

    scrapy startproject scrapy_charlie_chaplin
    cd scrapy_charlie_chaplin/
    scrapy genspider archive_charlie archive.org

Target website: 

> https://archive.org/search.php?query=subject%3A%22Charlie+Chaplin%22&and%5B%5D=mediatype%3A%22movies%22

Criteria: 

> any video that contains the keyword 'chaplin'

Data Model: 

> title, date, description, video_url, thumbnail_url

# Defining our Item
http://doc.scrapy.org/en/latest/intro/tutorial.html#defining-our-item

Items.py

    class ScrapyCharlieChaplinItem(scrapy.Item):
      title = scrapy.Field()
      date = scrapy.Field()
      description = scrapy.Field()
      video_url = scrapy.Field()
      video_type = scrapy.Field()
      thumbnail = scrapy.Field()

# CrawlSpider
http://doc.scrapy.org/en/latest/intro/tutorial.html#defining-our-item

Important:

1. start_urls
1. rules

which looks like this:

    class ArchiveCharlieSpider(CrawlSpider):
      name = "archive_charlie"
      allowed_domains = ["archive.org"]
      start_urls = (
          'https://archive.org/search.php?query=subject%3A%22Charlie+Chaplin%22&and%5B%5D=mediatype%3A%22movies%22',
      )

      rules = (
          # Extract links matching something like this:
          # '/search.php?query=subject%3A%22Charlie+Chaplin%22&and%5B%5D=mediatype%3A%22movies%22&page=2'
          # and follow links from them (no callback is specified, thus follow link.
          # this is the same as follow=True).
          Rule(LinkExtractor(allow=('\/search.php.*page=', ), )),

          # Extract links matching '/details/'
          # and parse them with the spider's method parse_item()
          Rule(LinkExtractor(allow=('\/details\/', )), callback='parse_item'),
      )

      def parse_item(self, response):
        pass

Now we need to work on parse_item() function to crawl the correct item information. The technology used here is called Selectors.
http://doc.scrapy.org/en/latest/topics/selectors.html#topics-selectors

This is my parsing function:

    def parse_item(self, response):
        item = ScrapyCharlieChaplinItem()

        item['title'] = response.xpath('//div[@class="relative-row row"]/div/h1/text()').extract()
        # if description does not exist, return
        if (not item['title']):
          return
        else:
          self.logger.info('now crawling item page: %s', response.url)

        item['description'] = response.xpath('//div[@class="relative-row row"]/div/div[@id="descript"]/text()').extract()
        if (not item['description']):
          item['description'] = response.xpath('//div[@class="relative-row row"]/div/div[@id="descript"]/p/text()').extract()

        item['date'] = response.xpath('//div[@class="relative-row row"]/div/div[@class="boxy"]/div[@class="boxy-ttl"]/text()').extract()
        item['video_url'] = response.xpath('//div[@class="relative-row row"]/div/div[@class="boxy quick-down"]/div[@class="format-group"]/a[@class="format-summary download-pill"]/@href').extract()
        if (not item['video_url']):
          return

        return item

And check the result by running:

    scrapy crawl archive_charlie -o charlie.json

The logging from terminal looks like this:

    ....
    2016-08-21 20:19:53 [scrapy] DEBUG: Scraped from <200 https://archive.org/details/funny_or_die_video_602d891174>
    {'date': [u'Uploaded by', u'\n          on 9/14/2014        ', u' Views'],
     'description': [u"japanese make up artist extra ordinaire so much that ramsa from tokyo commisioned carlito paquito aka av guy at the world famous comedy store, you know mitzi shore's place on sunset blvd took photos of him. wow. who cares?\n"],
     'title': [u'\n      ',
               u"Funny or Die Video 602d891174: bruce lee and jet li equals jackie chan equals charlie chaplin it's cool    "],
     'video_url': [u'/download/funny_or_die_video_602d891174/funny_or_die_video_602d891174.mp4',
                   u'/download/funny_or_die_video_602d891174/funny_or_die_video_602d891174.ogv',
                   u'/download/funny_or_die_video_602d891174/funny_or_die_video_602d891174_archive.torrent']}
    2016-08-21 20:19:53 [archive_charlie] INFO: now crawling item page: https://archive.org/details/funny_or_die_video_216de054ef
    ....

Now we've finished the crawling of raw data. Next step, we need to process the raw data using pipeline.

# Pipeline

Read: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

Implement process_item(self, item, spider) function to only keep the clean and useful data.
http://doc.scrapy.org/en/latest/topics/item-pipeline.html#process_item

    class ScrapyCharlieChaplinPipeline(object):
      def process_item(self, item, spider):

          # get clean title
          # TODO this can be improved
          item['title'] = item['title'][1].strip();

          # For description, remove empty line breaks, pre- and post-spaces
          # then concatenate all items in list into one string
          while '\n' in item['description']:
            item['description'].remove('\n')
          # TODO we might wish to do strip() for each string before joining
          # however, note that this is unicode, but string
          item['description'] = " ".join(item['description'])

          # TODO this can be improved
          item['date'] = item['date'][1].replace('\n', '').strip()

          # if any of video_url end with mp4, select that url
          for one_url in item['video_url']:
            if one_url.endswith('mp4'):
              item['video_format'] = 'mp4'
              # append archive.org as default prefix, if not currently exist
              if (one_url.startswith('/')):
                item['video_url'] = 'https://archive.org' + one_url
              else:
                item['video_url'] = one_url
              break

          # 3 fields are required: title, video_format and video_url
          if not item['title'] or not item['video_format'] or not item['video_url']:
            raise DropItem('Missing title, video_format or video_url, Drop Item')

          return item

# Result

Finally, the crawler is ready. The result looks like this:

    {"date": "on 9/14/2014", "video_format": "mp4", "description": "japanese make up artist extra ordinaire so much that ramsa from tokyo commisioned carlito paquito aka av guy at the world famous comedy store, you know mitzi shore's place on sunset blvd took photos of him. wow. who cares?\n", "video_url": "https://archive.org/download/funny_or_die_video_602d891174/funny_or_die_video_602d891174.mp4", "title": "Funny or Die Video 602d891174: bruce lee and jet li equals jackie chan equals charlie chaplin it's cool"},
    {"date": "on 10/10/2014", "video_format": "mp4", "description": "", "video_url": "https://archive.org/download/CharlieChaplinInCharlieShanghaiedAppleTV/Charlie Chaplin in Charlie Shanghaied - Apple TV.mp4", "title": "Charlie Chaplin In Charlie Shanghaied"},
    {"date": "on 10/7/2014", "video_format": "mp4", "description": "Charlie Chaplin meets Sergio Leone in this silent comedy short by Don Ford and David Schuttenhelm.\n", "video_url": "https://archive.org/download/funny_or_die_video_216de054ef/funny_or_die_video_216de054ef.mp4", "title": "Funny or Die Video 216de054ef: A Fistful of Dollar"},
