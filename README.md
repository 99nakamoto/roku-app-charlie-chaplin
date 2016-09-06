# How to run the spider crawler

Use spider_no_thumbnail:

    cd scrapy_charlie_chaplin/
    scrapy crawl spider_no_thumbnail -o output.json

Use spider_with_thumbnail: 

    cd scrapy_charlie_chaplin/
    scrapy crawl spider_with_thumbnail -o output.json

# Pass the data to Roku app

The Roku app will read data from: http://45.55.239.146/sample.json which look like this:

  {"Videos":
    ...some json format data...
    [{}, {}, {}]
    ...some json format data...
  }

## manual update

A manual way to do this, is to:

1. log into 45.55.239.146 which is my personal server

1. locate your www folder and open up sample.json

  sudo vi /var/www/html/sample.json
  
1. update this file like this:

paste your json file in the middle

    {"Videos":
    [your output.json here]
    }

# use scrapinghub

We can deploy the crawlers to cloud and run on cloud. 

    shub login
    shub deploy

After that, go to https://app.scrapinghub.com and run your crawler.

# How to test the Roku app

Go to the folder

  ./roku-app/

and zip everything. Then you can upload the zip to Roku TV.
