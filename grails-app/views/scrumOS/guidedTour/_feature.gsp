<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            steps: [
                {
                    element: "#window-title-bar-feature",
                    title: "Features",
                    placement: "left",
                    content: "You are now on your “Features”"
                },
                {
                    element: "#window-id-feature #window-toolbar .button-add",
                    title: "Features",
                    placement: "right",
                    content: "Here you can suggest features, just like you did for stories. "
                },
                {
                    element: "#window-id-feature .search .search-button",
                    title: "${message(code:'is.ui.guidedTour.feature.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.feature.search').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-feature .mini-value:first",
                    title: "${message(code:'is.ui.guidedTour.feature.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.feature.point').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-feature  .text-state:first",
                    title: "${message(code:'is.ui.guidedToura.feature.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.feature.estimated').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-feature .dropmenu:first",
                    title: "${message(code:'is.ui.guidedToura.feature.title').encodeAsJavaScript()}",
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