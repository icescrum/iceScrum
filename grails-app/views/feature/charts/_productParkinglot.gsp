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
<div id="productParkinglot${params.modal?'-modal':''}" title="${message(code:"is.chart.productParkinglot.title")}" class="chart-container">
</div>
<jq:jquery>
    $.jqplot.config.enablePlugins = true;
    line1 = ${values};
    var lines = [line1];
    var config = {
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
        text:'${message(code:"is.chart.productParkinglot.title")}',
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
          {label:'${message(code:"is.chart.productParkinglot.serie.name")}',color: '#afe2ff'}
          ],
      axes:{
          xaxis:{
            min:0,
            max:100,
            label:'${message(code:'is.chart.productParkinglot.xaxis.label')}',
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
    };
    <entry:point id="${controllerName}-${actionName}"/>
    plot1 = $.jqplot('productParkinglot${params.modal?'-modal':''}', lines, config);
    $('#productParkinglot${params.modal?'-modal':''}').on('replot', function(event) {
        plot1.replot( { resetAxes: true } );
    });
</jq:jquery>