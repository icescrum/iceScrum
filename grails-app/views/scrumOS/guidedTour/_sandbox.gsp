<g:set var="title" value="${message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()}"/>
<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
            steps: [
                {
                    element: "#window-title-bar-sandbox .title",
                    title: "${title}",
                    placement: "left",
                    content:"${message(code:'is.ui.guidedTour.sandbox.welcome').encodeAsJavaScript()}",
                    onShow: function (${tourName}) {
                        if (location.hash != '#sandbox') {
                            return $.icescrum.openWindow('sandbox');
                        }
                    }
                },
                {
                    element: "#window-id-sandbox #window-toolbar .button-add",
                    title: "${title}",
                    placement: "right",
                    template:"${message(code:'is.ui.guidedTour.templateWithSkip').encodeAsJavaScript()}",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.create').encodeAsJavaScript()}",
                    onShown: function (${tourName}) {
                        $('button[data-role="skip"]').click(function(){
                            ${tourName}.goTo(11);
                        })
                    },
                    onNext:function(${tourName}){
                        if (location.hash != '#sandbox/add') {
                            return $.icescrum.openWindow('sandbox/add');
                        }
                    }
                },
                {
                    element: "#storyname-field",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.name').encodeAsJavaScript()}",
                    onPrev: function (${tourName}) {
                        return $.icescrum.openWindow('sandbox');
                    }
                },
                {
                    element: "#s2id_story\\.type" , //"#window-id-sandbox #window-content-sandbox.field-select.clearfix.s2id_story.type",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.type').encodeAsJavaScript()}"
                },
                {
                    element: "#s2id_feature\\.id",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.feature').encodeAsJavaScript()}"
                },
                {
                    element: "s2id_dependsOn\\.id",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.dependance').encodeAsJavaScript()}"
                },
                {
                    element: "#storydescription-field",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.describe').encodeAsJavaScript()}"
                },
                {
                    element: "label[for=story\\.tags]+.select",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.tag').encodeAsJavaScript()}"
                },
                {
                    element: "#storyattachments-field",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.attach').encodeAsJavaScript()}"
                },
                {
                    element: "#storynotes",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.notes').encodeAsJavaScript()}"
                },
                {
                    element: "#submitForm",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.new.suggest').encodeAsJavaScript()}"
                },
                {
                    element: "#window-id-sandbox #window-content-sandbox :first .backlog .postit-story:first",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.story').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar  .navigation-item .button-accept",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.accept').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar  .navigation-item .button-copy",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.copy').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar  .navigation-item .button-delete",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.delete').encodeAsJavaScript()}"
                },
                {
                    element: "#window-toolbar  .navigation-item .button-view ",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.postit').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find(".navigation-item .button-view ").trigger('mouseenter');
                    }
                },
                {
                    element: "#window-toolbar  .navigation-item .button-print ",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.button.publishas').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find(".navigation-item .button-print").trigger('mouseenter');
                    }
                },
                {
                    element: "#window-id-sandbox .search .search-button",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.search').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-sandbox .postit-story:first p.postit-id",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.sandbox.story.number').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-sandbox .dropmenu-action:first .dropmenu .dropmenu-content",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.sandbox.story.number.manage').encodeAsJavaScript()}",
                    onShow:function(tour){
                        $("#window-toolbar").find("#window-content-sandbox .dropmenu-action:first .dropmenu .dropmenu-content").trigger('mouseenter');
                    }
                },
                {
                    element: "#window-content-sandbox .postit-story:first > div > div.state.task-state > div",
                    title: "${title}",
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