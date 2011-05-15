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
  <div id="productCumulativeflow" class="chart-container">
  <jq:jquery>
    $.jqplot.config.enablePlugins = true;
    line1 = ${suggested};
    line2 = ${accepted};
    line3 = ${estimated};
    line4 = ${planned};
    line5 = ${inprogress};
    line6 = ${done};

    plot1 = $.jqplot('productCumulativeflow', [line6,line5,line4,line3,line2,line1], {
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
    });
    $('#productCumulativeflow').bind('resize.jqplot', function(event, ui) {
        plot1.replot();
        $('#productCumulativeflow').find('.jqplot-table-legend').css('bottom','-12px');
    });
    $('#productCumulativeflow').find('.jqplot-table-legend').css('bottom','-12px');
  </jq:jquery>
  </div>
</is:chartView>
<g:if test="${withButtonBar}">
  <is:buttonBar>
    <is:button
            elementId="close"
            type="link"
            button="button-s button-s-black"
            update="window-content-${id}"
            remote="true"
            url="[controller:id,action:(id == 'project')?'dashboard':'index',params:[product:params.product]]"
            value="${message(code: 'is.button.close')}"/>
  </is:buttonBar>
</g:if>