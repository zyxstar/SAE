#encoding=utf-8

import os
import sae
import web


web.config.debug = True
urls = (
    '/', 'Index',
    '/echo', 'Echo'

)

app_root = os.path.dirname(__file__)
templates_root = os.path.join(app_root, 'templates')
render = web.template.render(templates_root, base='base')

class Echo:
    def GET(self):
        return "echo"
    def POST(self):
        web.header('Content-Type','application/octet-stream')
        filename= web.input(filename="file.txt").filename
        web.header('Content-Disposition',' attachment; filename="%s"' % filename )
        return web.input(content="no data").content

class Index:    
    def GET(self):        
        return "zyx home"






app = web.application(urls, globals()).wsgifunc()

application = sae.create_wsgi_app(app)
