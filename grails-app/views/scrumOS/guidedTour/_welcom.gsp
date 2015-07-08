<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#main",
                    title: "${message(code:'is.ui.guidedTour.title.welcom').encodeAsJavaScript()}",
                    placement: "top",
                    content: "${message(code:'is.ui.stepbystep.tour').encodeAsJavaScript()}"
                },
                {
                    element: "#navigation-avatar",
                    title:  "${message(code:'is.ui.guidedTour.title.welcom').encodeAsJavaScript()}",
                    placement: "left",
                    content:  "${message(code:'is.ui.guidedTour.logged').encodeAsJavaScript()}"
                },
                {
                    element: "#navigation-avatar",
                    title:  "${message(code:'is.ui.guidedTour.title.welcom').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.profile').encodeAsJavaScript()}"
                },
                {
                    element: "#is-logo",
                    title:  "${message(code:'is.ui.guidedTour.title.welcom').encodeAsJavaScript()}",
                    content:  "${message(code:'is.ui.guidedTour.islogo').encodeAsJavaScript()}"
                },
                {
                    element: "#menu-project",
                    title: "Menu",
                    content: "${message(code:'is.ui.guidedTour.menu').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>