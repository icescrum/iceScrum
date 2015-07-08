<g:set var="title" value="${message(code:'is.ui.guidedTour.actor.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#window-title-bar-actor",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.welcome').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-actor #window-toolbar .button-add",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.new').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-actor .search .search-button",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.search').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>