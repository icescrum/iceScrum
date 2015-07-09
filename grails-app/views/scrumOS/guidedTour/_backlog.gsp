<g:set var="title" value="${message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template: "${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#window-title-bar-backlog .title",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.backlog.welcome').encodeAsJavaScript()}",
                    onShow: function() {
                        if (location.hash != '#backlog') {
                            return $.icescrum.openWindow('backlog');
                        }
                    }
                },
                {
                    element: "#window-id-backlog #window-content-backlog :first .backlog .postit-story:first",
                    title: "${title}",
                    placement: "left",
                    content:"${message(code:'is.ui.guidedTour.backlog.story').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-backlog .editable:first",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.backlog.story.accepted').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-backlog .dropmenu-action:first .dropmenu",
                    title: "${title}",
                    placement: "top",
                    content: "${message(code:'is.ui.guidedTour.backlog.menu').encodeAsJavaScript()}",
                    onShown: function() {
                        $("#window-id-backlog").find("#window-content-backlog .dropmenu-action:first .dropmenu").trigger('mouseenter');
                    },
                    onHide: function() {
                        $("#window-id-backlog").find("#window-content-backlog .dropmenu-action:first .dropmenu").trigger('mouseleave');
                    }
                },
                {
                    element: "#window-id-backlog .search .search-button",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.backlog.search').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>