# If you are looking for a crawler tutorial

Read https://github.com/michaelran16/roku-app-charlie-chaplin/tree/master/scrapy_charlie_chaplin

# How to run the spider crawler

Use spider_no_thumbnail:

    cd scrapy_charlie_chaplin/
    scrapy crawl spider_no_thumbnail -o output.json

Use spider_with_thumbnail: 

    cd scrapy_charlie_chaplin/
    scrapy crawl spider_with_thumbnail -o output.json

# How data is passed to Roku app

The Roku app will read data from: http://45.55.239.146/sample.json which look like this:

  {"Videos":
    ...some json format data...
    [{}, {}, {}]
    ...some json format data...
  }

## manual update

A manual way to do this, is to:

1. log into my personal server

1. locate your www folder and open up sample.json

    sudo vi /var/www/html/sample.json
  
1. update this file like this:

paste your json file in the middle

    {"Videos":
    [your output.json here]
    }

## use scrapinghub

We can deploy the crawlers to cloud and run on cloud. 

    shub login
    shub deploy

After that, go to https://app.scrapinghub.com and run your crawler.

# How to test the Roku app

Go to the folder

    ./roku-app/

and zip everything. Then you can upload the zip to Roku TV.

# TL;DR

## spider_no_thumbnail

extends CrawlSpider

Given 1 start_urls, rules, and parse_item() function

The crawler will apply and follow the rules to open up all Item Pages, and use parse_item() to crawl all data needed for an item. 

This would not give up thumbnail because thumbnail is only present in the Item List Page, not the Item Page itself. 

## spider_with_thumbnail

extends scrapy.Spider

Given multiple start_urls, 1 default parse() function, and 1 customized parse_item() function

The crawler will first use parse() function to process the Item List, then use callback parse_item() function to process the Item Page. 

parse() is auto invoked by the crawler, and parse_item() is always invoked from inside parse() function. 

Most important is the use of request.meta, which passes in thumbnail to the request from Item List Page, to the parse_item() function

i.e. this code: request.meta['item'] = item
