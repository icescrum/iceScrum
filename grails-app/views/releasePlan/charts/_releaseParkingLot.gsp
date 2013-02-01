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
    <div id="releaseParkingLot" title="${message(code:"is.chart.releaseParkingLot.title")}" class="chart-container">
    </div>
    <jq:jquery>
      $.jqplot.config.enablePlugins = true;
      line1 = ${values};
      plot1 = $.jqplot('releaseParkingLot', [line1], {
          fontFamily:'Arial',
          legend:{
            show:true,
            renderer: $.jqplot.EnhancedLegendRenderer,
            location:'se',
            rendererOptions:{
                 numberColumns:1
            },
            fontSize: '11px',
            background:'#FFFFFF',
            fontFamily:'Arial'
          },
          title:{
            text:'${message(code:"is.chart.releaseParkingLot.title")}',
            fontFamily:'Arial'
          },
          grid: {
            background:'#FFFFFF',
            gridLineColor:'#CCCCCC',
            shadow:false,
            borderWidth:0
          },
          seriesDefaults:{
              renderer: $.jqplot.BarRenderer,
              rendererOptions:{barWidth: 50,barDirection:'horizontal', barPadding: 6, barMargin:15},
              shadowAngle:135
          },
          series:[
              {label:'${message(code:"is.chart.releaseParkingLot.serie.name")}',color: '#afe2ff'}
              ],
          axes:{
              xaxis:{
                min:0,
                max:100,
                label:'${message(code:'is.chart.releaseParkingLot.xaxis.label')}',
                tickOptions:{
                    formatString:'%d\%'
                }
              },
              yaxis:{
                renderer:$.jqplot.CategoryAxisRenderer,
                ticks:${featuresNames},
                rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer},
                tickOptions:{
                    fontSize:'11px',
                    fontFamily:'Arial'
                }
              }
          }
      });
      $('#releaseParkingLot').bind('resize.jqplot', function(event, ui) {
            plot1.replot();
            $('#releaseParkingLot').find('.jqplot-table-legend').css('bottom','-12px');
        });
        $('#releaseParkingLot').find('.jqplot-table-legend').css('bottom','-12px');
    </jq:jquery>
</div>
<g:if test="${!request.readOnly}">
    <is:buttonBar>
        <is:button
              href="#${controllerName}/${params.id}"
              elementId="close"
              type="link"
              button="button-s button-s-black"
              value="${message(code: 'is.button.close')}"/>
    </is:buttonBar>
</g:if>