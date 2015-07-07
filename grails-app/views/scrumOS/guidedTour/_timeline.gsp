<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            steps: [
                {
                    element: "#elem_timeline",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.timeline.welcome').encodeAsJavaScript()}",
                },
                {
                    element: "#window-id-timeline #window-toolbar .button-add",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.timeline.new').encodeAsJavaScript()}",
                },
                {
                    element: "#window-id-timeline .button-graph",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.timeline.chart').encodeAsJavaScript()}",
                    onShow: function (tour) {
                        $("#window-toolbar").find("#window-id-timeline .button-graph").trigger('mouseenter');
                    }
                },
                {
                    element: "#menu-documents-list",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.timeline.documents').encodeAsJavaScript()}"
                },
                {
                    element: "#menu-report-navigation-item",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement: "bottom",
                    content: "${message(code:'is.ui.guidedTour.timeline.publishas').encodeAsJavaScript()}"
                },
                {
                    element: ".tape-timeline-release:last",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.timeline.sprint').encodeAsJavaScript()}",
                },
                {
                    element: ".timeline-event-label .dropmenu:last",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement:"left",
                    content: "${message(code:'is.ui.guidedTour.timeline.update').encodeAsJavaScript()}",
                },
                {
                    element: ".timeline-sprint:last",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement : "left",
                    content: "${message(code:'is.ui.guidedTour.timeline.detail').encodeAsJavaScript()}",
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>