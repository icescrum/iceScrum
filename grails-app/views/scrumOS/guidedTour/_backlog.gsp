<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#elem_backlog",
                    title: "${message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.backlog.welcome').encodeAsJavaScript()}"
                },
                {
                    element: "#backlog-layout-window-backlog",
                    title: "${message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()}",
                    placement: "left",
                    content:"${message(code:'is.ui.guidedTour.backlog.accept').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-backlog .editable:first",
                    title: "${message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.backlog.point').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-backlog  .text-state:first",
                    title: "${message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.backlog.estimated').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-backlog .dropmenu-action:first .dropmenu .dropmenu-content",
                    title: "${message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.backlog.menu').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-id-backlog").find("#window-content-backlog .dropmenu-action:first .dropmenu .dropmenu-content").trigger('mouseenter');
                    }
                },
                {
                    element: "#window-id-backlog #window-content-backlog :first .backlog .postit-story:first",
                    title: "${message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.backlog.story.accepted').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-backlog .search .search-button",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.search').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>