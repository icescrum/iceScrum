<g:set var="title" value="${message(code:'is.ui.guidedTour.welcome.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#main",
                    title: "${title}",
                    placement: "top",
                    content: "${message(code:'is.ui.guidedTour.welcome.tour').encodeAsJavaScript()}"
                },
                {
                    element: "#navigation-avatar",
                    title:  "${title}",
                    placement: "left",
                    content:  "${message(code:'is.ui.guidedTour.welcome.logged').encodeAsJavaScript()}"
                },
                {
                    element: "#navigation-avatar",
                    title:  "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.welcome.profile').encodeAsJavaScript()}"
                },
                {
                    element: "#is-logo",
                    title:  "${title}",
                    content:  "${message(code:'is.ui.guidedTour.welcome.islogo').encodeAsJavaScript()}"
                },
                {
                    element: "#menu-project",
                    title: "${title}",
                    content: "${message(code:'is.ui.guidedTour.welcome.menu').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>