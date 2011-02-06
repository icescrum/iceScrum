/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 */

package org.icescrum.plugins.components

class TimelineTagLib {
  static namespace = 'is'


  def timeline = { attrs, body ->
    
    pageScope.timelineRoot = [
        band:[],
        height:attrs.height?:"100%",
        id:attrs.id,
        name:attrs.name,
        onScroll:attrs.onScroll?:null,
        container:attrs.container
    ]
    body()

    def jqCode = ""

    pageScope.timelineRoot.band.eachWithIndex{ it, index ->
        jqCode += "var eventSource${index} = new Timeline.DefaultEventSource();"
        if (it.themeOptions != null){
           jqCode += "var theme${index} = Timeline.ClassicTheme.create();"
           it.themeOptions.split(",").each{
            jqCode += "theme${index}.${it};"
           }
        }
    }

    jqCode += "var bandInfos = ["

    def bands = []
    def options = []

    pageScope.timelineRoot.band.eachWithIndex{ it, index ->

      def jsCode = "Timeline.createBandInfo({"
      jsCode += "eventSource:eventSource${index},"

      if (it.themeOptions != null){
        jsCode += "theme:theme${index},"
        it.remove('themeOptions')
      }

      if (it.options != null){
        it.options.index = index
        options << it.options
      }
      it.remove('options')

      jsCode += it.findAll{k, v -> (v != null)}.collect{k, v -> " $k:$v"}.join(',')
      jsCode += "})"
      bands << jsCode
    }
    jqCode += bands.join(",")
    jqCode += "];"

    options.each{ it ->
        if(it.syncWith != null)
          jqCode += "bandInfos[${it.index}].syncWith = ${it.syncWith};"
        if(it.highlight != null)
          jqCode += "bandInfos[${it.index}].highlight = ${it.highlight};"
    }

    def visible
    if (!attrs.startVisibleDate){
      visible = "${attrs.name}.getBand(0).setCenterVisibleDate(new Date());"
    }else{
      visible = "${attrs.name}.getBand(0).setMinVisibleDate(${attrs.startVisibleDate});"
    }

    jqCode += """
              ${attrs.name} = Timeline.create(document.getElementById('${attrs.id}'), bandInfos);
              ${visible}
              var resizeTimerID = null;
                function onResize() {
                    if (resizeTimerID == null) {
                        resizeTimerID = window.setTimeout(function() {
                            resizeTimerID = null;
                            ${attrs.name}.layout();
                        }, 500);
                    }
                }

              \$(window).bind('resize.timeline',function(){onResize();}).trigger('resize');
              \$('${attrs.container}').bind('beforeIsCloseWindow',function(){\$(window).unbind('resize.timeline');});
              \$('${attrs.container}').bind('onWindowToWidget',function(){\$(window).unbind('resize.timeline');});
              \$('#${attrs.id}').disableSelection();

              """

    pageScope.timelineRoot.band.eachWithIndex{ it, index ->
      jqCode += "${pageScope.timelineRoot.name}.loadJSON(${it.url},function(json, url){ eventSource${index}.loadJSON(json, url); });"
    }

    if (attrs.onScroll){
      jqCode += """var topBand = ${attrs.name}.getBand(0);
                    topBand.addOnScrollListener(function(band) {
                       ${attrs.onScroll}
                    });""" 
    }

    out << jq.jquery(null, jqCode)
    out << "<div id='${pageScope.timelineRoot.id}' style='height:${attrs.height}'></div>"
  }

  def timelineBand = { attrs, body ->
    pageScope.timelineBand = [
            width:"\"${attrs.height}\"",
            intervalPixels:attrs.intervalPixels,
            intervalUnit:"Timeline.DateTime.${attrs.intervalUnit}",
            themeOptions:attrs.themeOptions?:null,
            eventPainter:attrs.eventPainter?:null,
            overview:attrs.overview?:false,
            url:'\''+createLink(attrs)+'\''
    ]

    body()
    pageScope.timelineRoot.band << pageScope.timelineBand
  }

  def customBubble = { attrs, body ->
    def params = [
            enable : attrs.enable?:false,
            container: attrs.container?:"document.body",
            theme: attrs.theme?:"icescrum"
    ]
    pageScope.timelineRoot.customBubble = params.findAll{k, v -> v}
  }

  def bandOptions = { attrs, body ->
    if(!pageScope.timelineBand) return
    def params = [
            syncWith:attrs.syncWith?:null,
            highlight:attrs.highlight?:null
    ]
    pageScope.timelineBand.options = params.findAll{k, v -> v}
  }
}