<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            name:'project',
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#elem_project",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "bottom",
                    content: "${message(code:'is.ui.guidedTour.project.welcome').encodeAsJavaScript()}"
                },
                {
                    element: "#menu-chart-navigation-item",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.project.chart').encodeAsJavaScript()}"
                },
                {
                    element: "#menu-documents-list",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.project.documents').encodeAsJavaScript()}"
                },
                {
                    element: "#menu-report-navigation-item",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "bottom",
                    backdropPadding :50,
                    content: "${message(code:'is.ui.guidedTour.project.publishas').encodeAsJavaScript()}"
                },
                {
                    element: "#panel-chart-container",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    content: "${message(code:'is.ui.guidedTour.project.projectindicators').encodeAsJavaScript()}"
                },
                {
                    element: "#panel-activity",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.project.activities').encodeAsJavaScript()}"
                },
                {
                    element: "#panel-description",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.project.description').encodeAsJavaScript()}"
                },
                {
                    element: ".panel-vision:first",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.project.description.Release-vision').encodeAsJavaScript()}"
                },
                {
                    element: ".panel-doneDefinition:first",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.project.description.current.definition').encodeAsJavaScript()}"
                },
                {
                    element: ".panel-retrospective:first",
                    title: "${message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.project.description.current.retrospective').encodeAsJavaScript()}",
                    onNext: function (${tourName}) {
                        return $.icescrum.openWindow('sandbox');
                    }
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
})(jQuery);
</script>