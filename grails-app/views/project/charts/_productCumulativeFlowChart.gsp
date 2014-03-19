%{--
- Copyright (c) 2014 Kagilum SAS.
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
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<div id="productCumulativeflow${params.modal ?'-modal':''}" title="${message(code:"is.chart.productCumulativeflow.title")}" class="chart-container">
</div>
<jq:jquery>
    $.jqplot.config.enablePlugins = true;
    var line1 = ${suggested};
    var line2 = ${accepted};
    var line3 = ${estimated};
    var line4 = ${planned};
    var line5 = ${inprogress};
    var line6 = ${done};
    var lines = [line6,line5,line4,line3,line2,line1];
    var config = {
            legend:{
              show:true,
              renderer: $.jqplot.EnhancedLegendRenderer,
              location:'se',
              rendererOptions:{
                   numberColumns:4
              },
              fontSize: '11px',
              background:'#FFFFFF',
              fontFamily:'Arial'
            },
            title:{
            text:'${message(code:"is.chart.productCumulativeflow.title")}',
              fontFamily:'Arial'
            },
            grid: {
              background:'#FFFFFF',
              gridLineColor:'#CCCCCC',
              shadow:false,
              borderWidth:0
            },
            stackSeries: true,
            seriesDefaults: {
              pointLabels:{location:'s', ypadding:2},
              fill:true
            },
            series:[
                {label:'${message(code:"is.chart.productCumulativeflow.serie.done.name")}',color: '#009900'},
                {label:'${message(code:"is.chart.productCumulativeflow.serie.inprogress.name")}',color: '#FF9933'},
                {label:'${message(code:"is.chart.productCumulativeflow.serie.planned.name")}',color: '#CC3300'},
                {label:'${message(code:"is.chart.productCumulativeflow.serie.estimated.name")}',color: '#0099CC'},
                {label:'${message(code:"is.chart.productCumulativeflow.serie.accepted.name")}',color: '#0044CC'},
                {label:'${message(code:"is.chart.productCumulativeflow.serie.suggested.name")}',color: '#FFCC33'},
                ],
            axes:{
                xaxis:{
                  min:0,
                  label:'${message(code:'is.chart.productCumulativeflow.xaxis.label')}',
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
                  label:'${message(code:'is.chart.productCumulativeflow.yaxis.label')}',
                  tickOptions:{formatString:'%d'}
                }
            },
            cursor: {
              show: true,
              zoom: true
            },
            highlighter: {
              sizeAdjust: 7.5
            }
        };

    <entry:point id="${controllerName}-${actionName}"/>

    plot1 = $.jqplot('productCumulativeflow${params.modal ?'-modal':''}', lines, config);
    $('#productCumulativeflow${params.modal ?'-modal':''}').on('replot', function(event) {
        plot1.replot( { resetAxes: true } );
    });
</jq:jquery>