# -*- coding: utf-8 -*-
import scrapy


class ArchiveCharlieSpider(scrapy.Spider):
    name = "archive_charlie"
    allowed_domains = ["archive.org"]
    start_urls = (
        'http://www.archive.org/',
    )

    def parse(self, response):
        pass
