<g:set var="title" value="${message(code:'is.ui.guidedTour.'+tourName+'.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            name: "${tourName}",
            steps: [
                <g:include view="scrumOS/guidedTour/_${tourName}.gsp" model="[title:title, tourName:tourName, user: user]" />
            ],
            onEnd:function(){
                $.post($.icescrum.o.baseUrl + 'guidedTour', { ended:true, tourName:'${tourName}' });
            }
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>