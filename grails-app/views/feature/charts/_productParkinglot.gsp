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
<div id="productParkinglot" class="chart-container">
</div>
<jq:jquery>
  $.jqplot.config.enablePlugins = true;      
  line1 = ${values};
  plot1 = $.jqplot('productParkinglot', [line1], {
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
            tickOptions:{formatString:''}
          },
          yaxis:{
            label:'${message(code:'is.chart.productParkinglot.yaxis.label')}',
            renderer:$.jqplot.CategoryAxisRenderer,
            ticks:${featuresNames},
            rendererOptions:{tickRenderer:$.jqplot.CanvasAxisTickRenderer},
            tickOptions:{
                fontSize:'11px',
                fontFamily:'Arial',
                angle:30
            }
          }
      }
  });
  $('#productParkinglot').bind('resize.jqplot', function(event, ui) {
        plot1.replot();
      $('#productParkinglot').find('.jqplot-table-legend').css('bottom','-12px');
    });
    $('#productParkinglot').find('.jqplot-table-legend').css('bottom','-12px');
</jq:jquery>
</is:chartView>
<g:if test="${withButtonBar}">
  <is:buttonBar>
    <is:button
            elementId="close"
            type="link"
            button="button-s button-s-black"
            update="window-content-${id}"
            remote="true"
            url="[controller:params.referrer?.controller?:id,action:params.referrer?.action?:'list',params:[product:params.product]]"
            value="${message(code: 'is.button.close')}"/>
  </is:buttonBar>
   <jq:jquery>
      $('#menu-report-navigation-item').show();
      $('#menu-report-separator').show();
    </jq:jquery>
</g:if>