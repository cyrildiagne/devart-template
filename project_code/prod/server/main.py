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
import datetime

from google.appengine.ext import ndb

# from oauth2client import client
# from apiclient import sample_tools

DEFAULT_REPLAY_FOLDER = 'default_replay'

SECRET  = yaml.load( open("secret.yaml", 'r') )
API_KEY = SECRET['apikey']

class Replay(ndb.Model):
  """Models an individual Guestbook entry."""
  tag      = ndb.StringProperty()
  shortURL = ndb.StringProperty()
  date     = ndb.DateTimeProperty(auto_now_add=True)

def replay_key(replay_folder=DEFAULT_REPLAY_FOLDER):
  """Constructs a Datastore key for a Replay entity with guestbook_name."""
  return ndb.Key('Replay', replay_folder)

def shorten(url):
  gurl = 'https://www.googleapis.com/urlshortener/v1/url'
  data = json.dumps({'longUrl':url, 'key':API_KEY})
  req = urllib2.Request(gurl, data=data)
  req.add_header('Content-Type', 'application/json')
  results = json.load(urllib2.urlopen(req))
  return results['id']

class LastHandler(webapp2.RequestHandler):

  def options(self):
    self.response.headers.add_header('Access-Control-Allow-Origin', '*')
    self.response.headers.add_header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept')
    self.response.headers.add_header('Access-Control-Allow-Methods', 'POST, GET, PUT, DELETE')

  def post(self):
    self.response.headers.add_header("Access-Control-Allow-Origin", "*")

    key = self.request.get('key')
    if key == '' or key != API_KEY:
      self.response.write('error : key missing or wrong')
      return

    replay_tag = self.request.get('tag')
    if replay_tag != '':
      repl = Replay(parent=replay_key())
      repl.tag = replay_tag
      repl.shortURL = shorten('http://devartmrkalia.com/#scene='+replay_tag)
      repl.put()
      self.response.write('success')
    else:
      self.response.write('error : replay tag missing')

  def get(self):
    query = Replay.query(ancestor=replay_key()).order(-Replay.date)
    latests = query.fetch(1)
    if len(latests) is 0:
      self.response.write('empty.')
      return
    replay = latests[0]

    m11     = replay.tag.split('_')[-1]
    urlId = replay.shortURL.split('/')[-1]
    date    = str(replay.date+datetime.timedelta(hours=1))

    if self.request.get('json'):
      self.response.write('{"m11": "' + m11 + '",')
      self.response.write('"urlId": "' + urlId + '",')
      self.response.write('"date": "' + date + '"}')
    else:
      self.response.write('<html><head><link rel="stylesheet" href="./last/last.css"></head><body>')
      self.response.write('<div class="last_scene">')
      self.response.write('<img src="./last/m11/'+m11+'.png">')
      self.response.write('<p>Watch the replay of your performance at</p>')
      self.response.write('<a href="http://goo.gl/'+urlId+'">goo.gl/<span>'+urlId+'</span></a>')
      self.response.write('<p class="date" data-date="'+date+'"></p>')
      self.response.write('</div>')
      self.response.write('<script src="./vendor/js/jquery.min.js"></script>')
      self.response.write('<script src="./last/moment.js"></script>')
      self.response.write('<script src="./last/last.js"></script>')
      self.response.write('</body></html>')

class ReplayListHandler(webapp2.RequestHandler):
  def get(self):

    # query = Replay.query(ancestor=replay_key()).order(-Replay.date)
    # query = Replay.query(ancestor=replay_key())#.filter(Replay.tag == '1403083919161_138333_books')
    # query = Replay.query(Replay.tag == '1403083919161_138333_books')
    # replays = query.fetch(1)
    # if len(replays) is 0 :
    #   self.response.write('empty.')
    #   return
    # replay = replays[0]
    # query = Replay.query(Replay.date < replay.date).count() 
    # print query
    # self.response.write(len(replays))
    # return

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
  ('/list', ReplayListHandler),
  ('/last', LastHandler)
], debug=True)