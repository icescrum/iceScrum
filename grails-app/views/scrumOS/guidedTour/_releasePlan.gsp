<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            steps: [
                {
                    element: "#elem_releasePlan",
                    title: "${message(code:'is.ui.guidedTour.releasePlan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.releasePlan.welcome').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-releasePlan .button-add",
                    title: "${message(code:'is.ui.guidedTour.releasePlan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.releasePlan.new').encodeAsJavaScript()}"
                },
                {
                    element: "#local",
                    title: "${message(code:'is.ui.guidedTour.releasePlan.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.releasePlan.backlog').encodeAsJavaScript()}"
                },
                {
                    element: ".postit-rect:first",
                    title: "${message(code:'is.ui.guidedTour.releasePlan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.releasePlan.story').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-releasePlan  .event-overflow .event-container .dropmenu:first",
                    title: "${message(code:'is.ui.guidedTour.releasePlan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.releasePlan.sprint').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find("#window-content-releasePlan  .event-overflow .event-container .dropmenu:first").trigger('mouseenter');
                    } //pb fonctionne que quand pas de projet
                },
                {
                    element: "#menu-postit-sprint-9",
                    title: "${message(code:'is.ui.guidedTour.releasePlan.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.releasePlan.close.sprint').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>