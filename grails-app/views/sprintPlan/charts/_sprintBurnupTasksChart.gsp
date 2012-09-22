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
    <div id="sprintBurnupTasks" class="chart-container">
    </div>
    <jq:jquery>
        $.jqplot.config.enablePlugins = true;
       line1 = ${tasks};
    line2 = ${tasksDone};

    plot1 = $.jqplot('sprintBurnupTasks', [line1,line2], {
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
        text:'${message(code: "is.chart.sprintBurnupTasksChart.title")}',
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
        series:[
            {label:'${message(code: "is.chart.sprintBurnupTasksChart.serie.tasks.name")}',color: '#FFCC33'},
            {label:'${message(code: "is.chart.sprintBurnupTasksChart.serie.tasksDone.name")}',color: '#009900'},
            ],
        axes:{
            xaxis:{
              min:0,
              label:'${message(code: 'is.chart.sprintBurnupTasksChart.xaxis.label')}',
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
              label:'${message(code: 'is.chart.sprintBurnupTasksChart.yaxis.label')}',
              tickOptions:{formatString:'%d'}
            }
        },
        cursor: {
          show: true,
          zoom: true
        }
    });
    $('#sprintBurnupTasks').bind('resize.jqplot', function(event, ui) {
        plot1.replot();
        $('#sprintBurnupTasks').find('.jqplot-table-legend').css('bottom','-12px');
    });
    $('#sprintBurnupTasks').find('.jqplot-table-legend').css('bottom','-12px');
    </jq:jquery>
</div>
<g:if test="${withButtonBar}">
    <is:buttonBar>
        <is:button
                targetLocation="${controllerName+'/'+params.id}"
                elementId="close"
                type="link"
                button="button-s button-s-black"
                update="window-content-${controllerName}"
                remote="true"
                url="[controller:controllerName,action:'index',params:[id:params.id,product:params.product]]"
                value="${message(code: 'is.button.close')}"/>
    </is:buttonBar>
</g:if>