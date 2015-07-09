<g:set var="title" value="${message(code:'is.ui.guidedTour.actor.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template: "${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#window-title-bar-actor",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.welcome').encodeAsJavaScript()}",
                    onShow: function() {
                        if (location.hash != '#actor') {
                            return $.icescrum.openWindow('actor');
                        }
                    }
                },
                {
                    element: "#window-id-actor #window-toolbar .button-add",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.new').encodeAsJavaScript()}",
                    onShown: function() {
                        $('#window-id-actor').find("#window-toolbar .button-add").trigger('mouseenter');
                    },
                    onHide: function() {
                        $('#window-id-actor').find("#window-toolbar .button-add").trigger('mouseleave');
                    }
                },
                {
                    element: "#window-id-actor #window-toolbar .button-delete",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.delete').encodeAsJavaScript()}",
                    onShown: function() {
                        $('#window-id-actor').find("#window-toolbar .button-delete").trigger('mouseenter');
                    },
                    onHide: function() {
                        $('#window-id-actor').find("#window-toolbar .button-delete").trigger('mouseleave');
                    }
                },
                {
                    element: "#window-id-actor #window-toolbar #menu-display-navigation-item",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.viewType').encodeAsJavaScript()}",
                    onShown: function() {
                        $('#window-id-actor').find("#window-toolbar #menu-display-navigation-item a").trigger('mouseenter');
                    },
                    onHide: function() {
                        $('#window-id-actor').find("#window-toolbar #menu-display-navigation-item a").trigger('mouseleave');
                    }
                },
                {
                    element: "#menu-report-navigation-item",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.publishas').encodeAsJavaScript()}",
                    onShown: function() {
                        $("#window-id-actor").find("#menu-report-navigation-item a").trigger('mouseenter');
                    },
                    onHide: function() {
                        $("#window-id-actor").find("#menu-report-navigation-item a").trigger('mouseleave');
                    }
                },
                {
                    element: "#window-id-actor .search",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.actor.search').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>