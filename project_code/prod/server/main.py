#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import webapp2
import yaml
import json
import urllib2
import math
# from oauth2client.client import SignedJwtAssertionCredentials

class ReplayListHandler(webapp2.RequestHandler):
  def get(self):

    # retrieve complete list of items
    # TODO : SAVE A CACHE !!
    url = 'https://www.googleapis.com/storage/v1/b/mr-kalia-replays/o?fields=items(name,size)'
    data = json.load(urllib2.urlopen(url))
    items = data['items']
    pos = last = len(items)

    # if a specific scene was requested, use it as our scene list cursor
    name = self.request.get('scene')
    if name != '':
      for i in range(0, last):
        if items[i]['name'] == name:
          pos = i
          break

    # set number of scenes to include in list
    num = self.request.get('num')
    if num == '' : num = 100
    num = min( int(num), len(items))

    # set start / end position of list
    hnum  = num*0.5
    start_offset = end_offset = 0
    start = int(math.ceil(pos-hnum))
    if start < 0:
      start_offset = -start
      start = 0
    end = int(math.ceil(pos+hnum))
    if end > last:
      end_offset = end-last
      end = last
    start = int( max(start-end_offset, 0) )
    end   = int( min(end+start_offset, last) )

    print "{} & {}".format(end, len(items)-1)

    # send slice as json
    subarr = items[start:end+1]
    # self.response.write(json.dumps(items))
    self.response.headers.add_header("Access-Control-Allow-Origin", "*")
    self.response.write(json.dumps(subarr))

class TokenHandler(webapp2.RequestHandler):
  def get(self):
    secret = open("secret.yaml", 'r')
    keys = yaml.load(secret)
    iss = keys["iss"]
    key = keys["key"]
    scope = keys["scope"]
    # credentials = SignedJwtAssertionCredentials(iss, key, scope=scope)
    # self.response.write(credentials.access_token)

app = webapp2.WSGIApplication([
  ('/token', TokenHandler),
  ('/list', ReplayListHandler)
], debug=True)