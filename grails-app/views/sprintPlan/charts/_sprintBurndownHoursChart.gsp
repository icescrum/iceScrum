%{--
- Copyright (c) 2010 iceScrum Technologies.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
--}%
<div class="view-chart">
    <g:if test="${!request.readOnly}">
        <div class="panel-line">
              <button class="save-chart ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only">${message(code:'is.button.save.as.image')}</button>
        </div>
    </g:if>
    <div id="sprintBurndownHours" title="${message(code:"is.chart.sprintBurndownHoursChart.title")}" class="chart-container">
    </div>
    <jq:jquery>
        $.jqplot.config.enablePlugins = true;
        var line1 = ${remainingHours};

       <g:if test="${idealHours}">
          var line2 = ${idealHours};
          var lines = [line1,line2];
          var labels = [ {label:'${message(code: "is.chart.sprintBurndownHoursChart.serie.task.name")}',color: '#003399'},
                         {label:'${message(code: "is.chart.sprintBurndownHoursChart.serie.task.ideal")}',color: '#003344'}];
       </g:if>
       <g:else>
           var lines = [line1];
           var labels = [ {label:'${message(code: "is.chart.sprintBurndownHoursChart.serie.task.name")}',color: '#003399'}];
       </g:else>

    plot1 = $.jqplot('sprintBurndownHours', lines, {
        legend:{
          show:true,
          renderer: $.jqplot.EnhancedLegendRenderer,
          location:'se',
          rendererOptions:{
               numberColumns:2
          },
          fontSize: '11px',
          background:'#FFFFFF',
          fontFamily:'Arial'
        },
        title:{
        text:'${message(code: "is.chart.sprintBurndownHoursChart.title")}',
          fontFamily:'Arial'
        },
        grid: {
          background:'#FFFFFF',
          gridLineColor:'#CCCCCC',
          shadow:false,
          borderWidth:0
        },
        seriesDefaults: {
          pointLabels:{location:'s', ypadding:2}
        },
        series:labels,
        axes:{
            xaxis:{
              min:0,
              label:'${message(code: 'is.chart.sprintBurndownHoursChart.xaxis.label')}',
              ticks:${labels},
              renderer: $.jqplot.CategoryAxisRenderer,
              rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer},
              tickOptions:{
                  fontSize:'11px',
                  fontFamily:'Arial',
                  angle:-30
              }
            },
            yaxis:{
              min:0,
              label:'${message(code: 'is.chart.sprintBurndownHoursChart.yaxis.label')}',
              tickOptions:{formatString:'%.1f'}
            }
        },
        cursor: {
          show: true,
          zoom: true
        }
    });
     $('#sprintBurndownHours').bind('resize.jqplot', function(event, ui) {
        plot1.replot();
        $('#sprintBurndownHours').find('.jqplot-table-legend').css('bottom','-12px');
    });
    $('#sprintBurndownHours').find('.jqplot-table-legend').css('bottom','-12px');
    </jq:jquery>
</div>
<g:if test="${withButtonBar && !request.readOnly}">
    <is:buttonBar>
        <is:button
              href="#${controllerName}/${params.id}"
              elementId="close"
              type="link"
              button="button-s button-s-black"
              value="${message(code: 'is.button.close')}"/>
    </is:buttonBar>
</g:if>