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
<g:setProvider library="jquery"/>
<is:chartView>
    <div id="sprintBurndownHours" class="chart-container">
    </div>
    <jq:jquery>
        $.jqplot.config.enablePlugins = true;
       line1 = ${remainingHours};
    line2 = ${idealHours};

    plot1 = $.jqplot('sprintBurndownHours', [line1,line2], {
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
        series:[ {label:'${message(code: "is.chart.sprintBurndownHoursChart.serie.task.name")}',color: '#003399'},
                 {label:'${message(code: "is.chart.sprintBurndownHoursChart.serie.task.ideal")}',color: '#003344'}],
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
              tickOptions:{formatString:'%d'}
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
</is:chartView>
<g:if test="${withButtonBar}">
    <is:buttonBar>
        <is:button
                targetLocation="${controllerName+'/'+params.id}"
                elementId="close"
                type="link"
                button="button-s button-s-black"
                update="window-content-${id}"
                remote="true"
                url="[controller:id,action:'index',params:[id:params.id,product:params.product]]"
                value="${message(code: 'is.button.close')}"/>
    </is:buttonBar>
</g:if>