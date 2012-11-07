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
  <div id="productBurnDown" class="chart-container">
  </div>
  <jq:jquery>
    $.jqplot.config.enablePlugins = true;    
    line1 = ${userstories};
    line2 = ${technicalstories};
    line3 = ${defectstories};
    plot1 = $.jqplot('productBurnDown', [line1, line2,line3], {
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
          text:'${message(code:"is.chart.productBurnDown.title")}',
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
          {label: '${message(code:'is.chart.productBurnDown.series.userstories.name')}',color: '#0099CC'},
          {label: '${message(code:'is.chart.productBurnDown.series.technicalstories.name')}',color: '#FF9933'},
          {label: '${message(code:'is.chart.productBurnDown.series.defectstories.name')}',color: '#CC3300'}
        ],
        axes: {
            xaxis: {
              ticks:${labels},
              label:'${message(code:'is.chart.productBurnDown.xaxis.label')}',
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
                label:'${message(code:'is.chart.productBurnDown.yaxis.label')}',
                tickOptions:{formatString:'%d'}
            }
        }
    });
    $('#productBurnDown').bind('resize.jqplot', function(event, ui) {
        plot1.replot();
        $('#productBurnDown').find('.jqplot-table-legend').css('bottom','-12px');
    });
    $('#productBurnDown').find('.jqplot-table-legend').css('bottom','-12px');
  </jq:jquery>
</div>
<g:if test="${withButtonBar}">
  <is:buttonBar>
      <is:button
              href="#${controllerName}"
              elementId="close"
              type="link"
              button="button-s button-s-black"
              value="${message(code: 'is.button.close')}"/>
  </is:buttonBar>
</g:if>