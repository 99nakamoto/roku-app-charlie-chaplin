# -*- coding: utf-8 -*-
import scrapy

from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor

from scrapy_charlie_chaplin.items import ScrapyCharlieChaplinItem


class SpiderNoThumbnail(CrawlSpider):
    name = "spider_no_thumbnail"
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
