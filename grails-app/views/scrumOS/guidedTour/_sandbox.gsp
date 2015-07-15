{
    element: "#window-title-bar-sandbox .title",
    title: "${title}",
    placement: "right",
    content:"${message(code:'is.ui.guidedTour.sandbox.welcome').encodeAsJavaScript()}",
    onShow: function () {
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
    onShown: function (tour) {
        $('button[data-role="skip"]').click(function(){
            tour.goTo(tour.getCurrentStep() + 9);
        })
    },
    onNext:function(){
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
    onPrev: function () {
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
    element: "#window-content-sandbox .postit-story:first p.postit-id",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sandbox.story.number').encodeAsJavaScript()}"
},
{
    element: "#window-content-sandbox .postit-story:first .dropmenu-action .dropmenu",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sandbox.story.menu').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-content-sandbox").find(".postit-story:first .dropmenu-action .dropmenu").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-content-sandbox").find(".postit-story:first .dropmenu-action .dropmenu").trigger('mouseleave');
    }
},
{
    element: "#window-toolbar .button-accept",
    title: "${title}",
    placement: "bottom",
    content: "${message(code:'is.ui.guidedTour.sandbox.multiple').encodeAsJavaScript()}"
},
{
    element: "#window-toolbar  .navigation-item .button-view ",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sandbox.postit').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-toolbar").find(".navigation-item .button-view ").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-toolbar").find(".navigation-item .button-view ").trigger('mouseleave');
    }
},
{
    element: "#window-toolbar  .navigation-item .button-print ",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sandbox.publishas').encodeAsJavaScript()}",
    onShown:function() {
        $("#window-toolbar").find(".navigation-item .button-print").trigger('mouseenter');
    },
    onHide:function() {
        $("#window-toolbar").find(".navigation-item .button-print").trigger('mouseleave');
    }
},
{
    element: "#window-id-sandbox .search .search-button",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sandbox.search').encodeAsJavaScript()}"
},
{
    element: "#window-content-sandbox .postit-story:first > div > div.state.task-state > div",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sandbox.accept').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-content-sandbox").find(".postit-story:first .dropmenu-action .dropmenu").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-content-sandbox").find(".postit-story:first .dropmenu-action .dropmenu").trigger('mouseleave');
    }
}