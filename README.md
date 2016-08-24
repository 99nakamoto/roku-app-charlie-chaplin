# How to run the spider crawler

The old crawler:

    cd scrapy_charlie_chaplin/
    scrapy crawl archive_charlie -o output.json

The new crawler with thumbnail: 

    cd scrapy_charlie_chaplin/
    scrapy crawl archive_charlie_thumbnail -o output.json

# Pass the data to Roku app

The Roku app will read data from: http://45.55.239.146/sample.json which look like this:

    {"Videos":
        ...some json format data...
        [{}, {}, {}]
        ...some json format data...
    }

# How to test the Roku app

Go to ./roku-app/ folder and zip everything, then you can upload the zip to Roku TV.
