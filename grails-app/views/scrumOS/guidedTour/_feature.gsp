<g:set var="title" value="${message(code:'is.ui.guidedTour.feature.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#window-title-bar-feature",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.feature.welcome').encodeAsJavaScript()}",
                    onShow: function (${tourName}) {
                        if (location.hash != '#feature') {
                            return $.icescrum.openWindow('feature');
                        }
                    }
                },
                {
                    element: "#window-id-feature #window-toolbar .button-add",
                    title: "${title}",
                    placement: "right",
                    content: ${message(code:'is.ui.guidedTour.feature.new').encodeAsJavaScript()}
                },
                {
                    element: "#window-id-feature .search .search-button",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.feature.search').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-feature .mini-value:first",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.feature.point').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-feature  .text-state:first",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.feature.estimated').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-feature .dropmenu:first",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.feature.estimated').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find("#window-content-feature .dropmenu:first").trigger('mouseenter');
                    }
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        </g:if>
    })(jQuery);
</script>