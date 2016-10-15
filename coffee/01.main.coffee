request = require "request"

#APP_URL = "http://localhost:8088"
#WEB_URL = "http://localhost:8080"
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
            <br/>
            <a href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=#{item.sceneid}"> <span class="glyphicon glyphicon-pencil"></span> Edit </a> &nbsp; &nbsp; &nbsp;<a href="#" id="delete_#{item.sceneid}"><span class="glyphicon glyphicon-remove"></span> Delete </a>
          </div>
        </div>
        <!-- Modal Window for Message-->
<div class="modal fade bs-example-modal-sm" tabindex="-1" id="messageModal" role="dialog" aria-labelledby="mySmallModalLabel">
  <div class="modal-dialog modal-sm" role="document">
    <div class="modal-content">
       Scene deleted.
    </div>
  </div>
</div>
<script>
$(function() {
    console.log("ready!");
    $('a').click(function(event) {
        console.log(event.target.id);
        if(/^delete/.test(event.target.id)) {
          var scene_id = event.target.id.split("delete_")[1];
          var url = "http://uinnova.com:8088/usm/api/v1/scenes/delete/" + scene_id;
          $.get( url, function(data, status) {
            var json_data = JSON.stringify(data);
            console.log(json_data);
            $('#messageModal').modal('show')     
          });
          event.preventDefault();
        }
    })
});
</script>
        """
      pre = pre + """
        <div class="col-md-12">
          <h3>Samples</h3>
        </div>         
        <div class="panel panel-success col-md-3">
          <div class="panel-heading">
            <h3 class="panel-title">DC Sample 001</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=sample001_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcbsample/sample001.jpg"/>
            </a>
          </div>
        </div>     
        <div class="panel panel-warning col-md-3">
          <div class="panel-heading">
            <h3 class="panel-title">Xransformer</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=Xransformer_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcbsample/100.jpg"/>
            </a>
          </div>
        </div>
        <div class="panel panel-primary col-md-3">
          <div class="panel-heading">
            <h3 class="panel-title">DC843</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=843_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcbsample/DC843.jpg"/>
            </a>
          </div>
        </div>
        <div class="panel panel-danger col-md-3">
          <div class="panel-heading">
            <h3 class="panel-title">DC2619</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=DC2619_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcbsample/DC2619.jpg"/>
            </a>
          </div>
        </div>
        <div class="panel panel-info col-md-3">
          <div class="panel-heading">
            <h3 class="panel-title">Large DC</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=largeDC_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcbsample/largeDC.jpg"/>
            </a>
          </div>
        </div>
        <div class="panel panel-success col-md-3">
          <div class="panel-heading">
            <h3 class="panel-title">DC2208</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=DC2208_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcbsample/DC2208.jpg"/>
            </a>
          </div>
        </div>
        <div class="panel panel-warning col-md-3">
          <div class="panel-heading">
            <h3 class="panel-title">ECC</h3>
          </div>
          <div class="panel-body">
            <a id="scene" href="#{WEB_URL}/uBuilderWebPlayer.html?userid=#{widget.uid}&scene_id=ECC_1">
                <img id="image" src="https://s3-us-west-1.amazonaws.com/udcbsample/ECC.jpg"/>
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
      name: 'uDCB Private Scenes'
      description: 'Show uDCB Private Scenes.'
      content: fs.readFileSync(path.resolve(__dirname, './templates/widget.tpl'))
    callback null, widgets
    return

  module.exports = Widget
  return