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
  <div id="releaseBurnDown" class="chart-container">
  </div>
  <jq:jquery>
    $.jqplot.config.enablePlugins = true;
    line1 = ${userstories};
    line2 = ${technicalstories};
    line3 = ${defectstories};
    plot1 = $.jqplot('releaseBurnDown', [line1, line2,line3], {
        stackSeries: true,
        legend:{
          show:true,
          renderer: $.jqplot.EnhancedLegendRenderer,
          location:'se',
          rendererOptions:{
               numberColumns:3
          },
          fontSize: '11px',
          background:'#FFFFFF',
          fontFamily:'Arial'
        },
        title:{
          text:'${message(code:"is.chart.releaseBurnDown.title")}',
          fontFamily:'Arial'
        },
        grid: {
          background:'#FFFFFF',
          gridLineColor:'#CCCCCC',
          shadow:false,
          borderWidth:0
        },
        seriesDefaults: {
          renderer: $.jqplot.BarRenderer,
          rendererOptions: {barWidth: 50},
          pointLabels:{stackedValue: true,location: 's',ypadding:0}
        },
        series: [
          {label: '${message(code:'is.chart.releaseBurnDown.series.userstories.name')}',color: '#0099CC'},
          {label: '${message(code:'is.chart.releaseBurnDown.series.technicalstories.name')}',color: '#FF9933'},
          {label: '${message(code:'is.chart.releaseBurnDown.series.defectstories.name')}',color: '#CC3300'}],
        axes: {
            xaxis: {
              ticks:${labels},
              label:'${message(code:'is.chart.releaseBurnDown.xaxis.label')}',
              renderer: $.jqplot.CategoryAxisRenderer,
              rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer},
              tickOptions:{
                  fontSize:'11px',
                  fontFamily:'Arial',
                  angle:-30
              }
            },
            yaxis: {
                min: 0,
                label:'${message(code:'is.chart.releaseBurnDown.yaxis.label')}',
                tickOptions:{formatString:'%d'}
            }
        }
    });
    $('#releaseBurnDown').bind('resize.jqplot', function(event, ui) {
        plot1.replot();
        $('#releaseBurnDown').find('.jqplot-table-legend').css('bottom','-12px');
    });
    $('#releaseBurnDown').find('.jqplot-table-legend').css('bottom','-12px');
  </jq:jquery>
</div>
<is:buttonBar>
  <is:button
          targetLocation="${controllerName+'/'+params.id}"
          elementId="close"
          type="link"
          button="button-s button-s-black"
          remote="true"
          url="[controller:controllerName, action:'index',id:params.id, params:[product:params.product]]"
          update="window-content-${controllerName}"
          value="${message(code: 'is.button.close')}"/>
</is:buttonBar>