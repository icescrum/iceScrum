<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            steps: [
                {
                    element: "#window-id-actor",
                    title: "${message(code:'is.ui.guidedTour.actor.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.welcome').encodeAsJavaScript()}",
                },
                {
                    element: "#window-id-actor #window-toolbar .button-add",
                    title: "${message(code:'is.ui.guidedTour.actor.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.welcome').encodeAsJavaScript()}",
                },
                {
                    element: "#window-id-actor .search .search-button",
                    title: "${message(code:'is.ui.guidedTour.actor.title').encodeAsJavaScript()}",
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