request = require "request"

# APP_URL = "http://localhost:8088"
# WEB_URL = "http://localhost:8080"
APP_URL = "http://www.uinnova.com:8088"
WEB_URL = "http://www.uinnova.com"

do (module) ->
  'use strict'
  async = require('async')
  fs = require('fs')
  path = require('path')
  http = require('http')
  templates = module.parent.require('templates.js')
  app = undefined
  Widget = templates: {}

  Widget.init = (params, callback) ->
    loadTemplate = (template, next) ->
      fs.readFile path.resolve(__dirname, './templates/' + template), (err, data) ->
        if err
          console.log err.message
          return next(err)
        Widget.templates[template] = data.toString()
        next null
        return
      return

    app = params.app
    templatesToLoad = [
      'widget.tpl'
      'uDCB.tpl'
    ]
    async.each templatesToLoad, loadTemplate
    callback()
    return

  Widget.renderAarstatusWidget = (widget, callback) ->  
    pre = '' + fs.readFileSync(path.resolve(__dirname, './templates/uDCB.tpl'))   
    console.log "user_id = #{widget.uid}"
    
    request "#{APP_URL}/usm/api/v1/scenes/#{widget.uid}", (error, response, body) ->
      data = JSON.parse body
      pre = pre + "<br>"
      for item in data
        pre = pre + """
        <div class="panel panel-info col-md-2">
          <div class="panel-heading">
            <h4 class="panel-title">#{item.name}</h4>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=#{item.sceneid}">
                 <img id="image" src="#{item.image}"/>
            </a>
          </div>
        </div> 
        """
      pre = pre + """
        <div class="col-md-12">
          <h3>Samples</h3>
        </div>         
        <div class="panel panel-success col-md-4">
          <div class="panel-heading">
            <h3 class="panel-title">DC Sample 001</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=sample001_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcb/sample001.png"/>
            </a>
          </div>
        </div>     
        <div class="panel panel-warning col-md-4">
          <div class="panel-heading">
            <h3 class="panel-title">DC Sample 002</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=sample001_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcb/sample001.png"/>
            </a>
          </div>
        </div>    
      """
      pre = pre.replace(new RegExp("xxx", "g"), widget.uid)   
      console.log "== render widget content == \n #{pre} \n ============="
      callback null, pre
      return     

  Widget.defineWidget = (widgets, callback) ->
    widgets.push
      widget: 'arrstatus'
      name: 'MT5225 Server Status'
      description: 'Shows MT5225 Server Status.'
      content: fs.readFileSync(path.resolve(__dirname, './templates/widget.tpl'))
    callback null, widgets
    return

  module.exports = Widget
  return