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
<div id="productBurnup${params.modal ?'-modal':''}" title="${message(code:'is.chart.productBurnUp.title')}" class="chart-container">
</div>
<jq:jquery>
    $.jqplot.config.enablePlugins = true;
    line1 = ${all};
    line2 = ${done};
    var lines = [line1, line2];
    var config = {
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
          text:'${message(code:"is.chart.productBurnUp.title")}',
          fontFamily:'Arial'
        },
        grid: {
          background:'#FFFFFF',
          gridLineColor:'#CCCCCC',
          shadow:false,
          borderWidth:0
        },
        seriesDefaults: {
          pointLabels:{location:'n', ypadding:2}
        },
        series:[
            {label:'${message(code:"is.chart.productBurnUp.serie.all.name")}',color: '#FFCC33'},
            {label:'${message(code:"is.chart.productBurnUp.serie.done.name")}',color: '#009900'}
            ],
        axes:{
            xaxis:{
              ticks:${labels},
              label:'${message(code:'is.chart.productBurnUp.xaxis.label')}',
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
            label:'${message(code:'is.chart.productBurnUp.yaxis.label')}',
            tickOptions:{formatString:'%d'}}
        },
        cursor: {
          show: true,
          zoom: true
        }
    };

    <entry:point id="${controllerName}-${actionName}"/>

    plot1 = $.jqplot('productBurnup${params.modal ?'-modal' :''}', lines, config);
    $('#productBurnup${params.modal ?'-modal':''}').on('replot', function(event) {
        plot1.replot( { resetAxes: true } );
    });
</jq:jquery>