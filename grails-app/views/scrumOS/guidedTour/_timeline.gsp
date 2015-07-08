<g:set var="title" value="${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#window-title-bar-timeline",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.timeline.welcome').encodeAsJavaScript()}",
                    onShow: function (${tourName}) {
                        if (location.hash != '#timeline') {
                            return $.icescrum.openWindow('timeline');
                        }
                    }
                },
                {
                    element: "#window-id-timeline #window-toolbar .button-add",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.timeline.new').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-timeline .button-graph",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.timeline.chart').encodeAsJavaScript()}",
                    onShow: function (tour) {
                        $("#window-toolbar").find("#window-id-timeline .button-graph").trigger('mouseenter');
                    }
                },
                {
                    element: "#menu-documents-list",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.timeline.documents').encodeAsJavaScript()}"
                },
                {
                    element: "#menu-report-navigation-item",
                    title: "${title}",
                    placement: "bottom",
                    content: "${message(code:'is.ui.guidedTour.timeline.publishas').encodeAsJavaScript()}"
                },
                {
                    element: ".tape-timeline-release:last",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.timeline.sprint').encodeAsJavaScript()}"
                },
                {
                    element: ".timeline-event-label .dropmenu:last",
                    title: "${title}",
                    placement:"left",
                    content: "${message(code:'is.ui.guidedTour.timeline.update').encodeAsJavaScript()}"
                },
                {
                    element: ".timeline-sprint:last",
                    title: "${title}",
                    placement : "left",
                    content: "${message(code:'is.ui.guidedTour.timeline.detail').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>