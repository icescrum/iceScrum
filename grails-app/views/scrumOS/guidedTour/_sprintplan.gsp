<g:set var="title" value="${message(code:'is.ui.guidedTour.sprintplan.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#window-title-bar-sprintPlan .title",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.welcome').encodeAsJavaScript()}",
                    onShow: function (${tourName}) {
                        if (location.hash != '#sprintPlan') {
                            return $.icescrum.openWindow('sprintPlan');
                        }
                    }
                },
                {
                    element: "#window-id-sprintPlan .button-add",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.new').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-sprintPlan",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.depend').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan  .button-filter",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.alltask').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find("#window-id-sprintPlan .button-filter").trigger('mouseenter');
                    }
                },
                {
                    element: "#window-id-sprintPlan  .button-activate",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.validated').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan  .button-close",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.close').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan  .button-create",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.new').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find("#window-id-sprintPlan .button-create").trigger('mouseenter');
                    }
                },
                {
                    element: ".dropmenu-action .dropmenu:first",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.urgent.task').encodeAsJavaScript()}"
                },
                {
                    element: ".dropmenu-action .dropmenu:last",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.recurring.task').encodeAsJavaScript()}"
                },
                {
                    element: "#dropmenu",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.task').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar > li.navigation-item.separator.button-activate",
                    title: "${title}",
                    placement: "bottom",
                    content: "${message(code:'is.ui.guidedTour.sprintplan.sprint').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sprintPlan .search .search-button",
                    title: "${title}",
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