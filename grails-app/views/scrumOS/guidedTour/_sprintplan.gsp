<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            steps: [
                {
                    element: "#elem_sprintPlan",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.welcome').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan .button-add",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.new').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-sprintPlan",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.depend').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan  .button-filter",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.timeline.alltask').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find("#window-id-sprintPlan .button-filter").trigger('mouseenter');
                    }
                },
                {
                    element: "#window-id-sprintPlan  .button-activate",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.validated').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan  .button-close",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.close').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan  .button-create",
                    title: "${message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.timeline.documents').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find("#window-id-sprintPlan .button-create").trigger('mouseenter');
                    }
                },
                {
                    element: ".dropmenu-action .dropmenu:first",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.urgent.task').encodeAsJavaScript()}"
                },
                {
                    element: ".dropmenu-action .dropmenu:last",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.recurring.task').encodeAsJavaScript()}"
                },
                {
                    element: "#dropmenu",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.task').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar > li.navigation-item.separator.button-activate",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "bottom",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.sprint').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan .search .search-button",
                    title: "${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.search').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>