# -*- coding: utf-8 -*-

from scrapy.exceptions import DropItem


class ScrapyCharlieChaplinPipeline(object):
    def process_item(self, item, spider):

        # get clean title
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
        
        # set the thumbnail url
        if (item['thumbnail'] and item['thumbnail'].startswith('/')):
              item['thumbnail'] = 'https://archive.org' + item['thumbnail']

        # 3 fields are required: title, video_format and video_url
        if not item['title'] or not item['video_format'] or not item['video_url']:
          raise DropItem('Missing title, video_format or video_url, Drop Item')

        # if the keyword Charlie Chaplin is not in title or description, drop item
        # if 'charlie' not in item['title'].lower() and
        #   'chaplin' not in item['title'].lower()) and
        #   'charlie' not in item['description'].lower() and
        #   'chaplin' not in item['description'].lower():
        #   raise DropItem('The item does not contain keyword charlie or chaplin, Drop Item')

        if ('charlie' not in item['title'].lower() and
        'chaplin' not in item['description'].lower() and
        'charlie' not in item['description'].lower() and
        'chaplin' not in item['description'].lower()):
          raise DropItem('The item does not contain keyword charlie or chaplin, Drop Item')

        return item
