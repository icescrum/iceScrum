<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            steps: [
                {
                    element: "#elem_sandbox",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "right",
                    content:"${message(code:'is.ui.guidedTour.sandbox.welcome').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sandbox #window-toolbar .button-add",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.create').encodeAsJavaScript()}",
                    // add yes or skyp if no goTo() step number ? else nextstep
                    onYes: function (${tourName}) {
                        if (location.hash != '#sandbox/add') {
                            $.icescrum.openWindow('sandbox/add');
                        }
                    }
                },
                {
                    element: "#storyname-field",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.name').encodeAsJavaScript()}",
                    onPrev: function (${tourName}) {
                        $.icescrum.openWindow('sandbox');
                    }
                },
                {
                    element: "#s2id_story\\.type" , //"#window-id-sandbox #window-content-sandbox.field-select.clearfix.s2id_story.type",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.type').encodeAsJavaScript()}"
                },
                {
                    element: "#s2id_feature\\.id",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.feature').encodeAsJavaScript()}"
                },
                {
                    element: "s2id_dependsOn\\.id",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.dependance').encodeAsJavaScript()}"
                },
                {
                    element: "#storydescription-field",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.Describe').encodeAsJavaScript()}"
                },
                {
                    element: "label[for=story\\.tags]",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.tag').encodeAsJavaScript()}"
                },
                {
                    element: "#storyattachments-field",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.Attach').encodeAsJavaScript()}"
                },
                {
                    element: "#storynotes",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.notes').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar  .navigation-item .button-accept",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.accept').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar  .navigation-item .button-copy",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.copy').encodeAsJavaScript()}"
                },//$('#menu-postit-story-76 ').trigger('mouseenter')
                {
                    element: "#window-toolbar  .navigation-item .button-delete",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.delete').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar  .navigation-item .button-view ",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.postit').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find(".navigation-item .button-view ").trigger('mouseenter');
                    }
                },
                {
                    element: "#window-toolbar  .navigation-item .button-print ",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.publishas').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find(".navigation-item .button-print").trigger('mouseenter');
                    }
                },
                {
                    element: "#window-id-sandbox .search .search-button",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.search').encodeAsJavaScript()}"
                },
                {
                    element: "#submitForm",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.suggest').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sandbox #window-content-sandbox :first .backlog .postit-story:first",
                    title: "${message(code:'is.ui.guidedTour.product.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.story').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-sandbox .postit-story:first p.postit-id",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.story.number').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-sandbox .dropmenu-action:first .dropmenu .dropmenu-content",
                    title: "${message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sandbox.story.number.manage').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find("#window-content-sandbox .dropmenu-action:first .dropmenu .dropmenu-content").trigger('mouseenter');
                    }
                }, //pb
                {
                    element: "#window-content-sandbox .postit-story:first > div > div.state.task-state > div",
                    title: "${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.accept').encodeAsJavaScript()}"
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.restart();
        $('#submitForm').click(function () {
            ${tourName}.goTo(14);
        });
        </g:if>
    })(jQuery);
</script>