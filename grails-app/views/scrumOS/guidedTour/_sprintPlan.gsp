{
    element: "#window-title-bar-sprintPlan .title",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.welcome').encodeAsJavaScript()}",
    onShow: function() {
        if (location.hash != '#sprintPlan') {
            return $.icescrum.openWindow('sprintPlan');
        }
    }
},
{
    element: "#window-id-sprintPlan .button-add",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.new').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan  .button-filter",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.alltask').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-sprintPlan").find("#window-toolbar .button-filter").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-sprintPlan").find("#window-toolbar .button-filter").trigger('mouseleave');
    }
},
{
    element: "#window-id-sprintPlan  .button-close",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.close').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan  #menu-documents-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.documents').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-sprintPlan").find("#window-toolbar #menu-documents-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-sprintPlan").find("#window-toolbar #menu-documents-navigation-item a").trigger('mouseleave');
    }
},
{
    element: "#window-id-sprintPlan #menu-chart-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.chart').encodeAsJavaScript()}",
    onShown: function() {
        $("#menu-chart-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#menu-chart-navigation-item a").trigger('mouseleave');
    }
},
{
    element: "#window-id-sprintPlan .dropmenu-action #menu-urgent",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.urgent.task').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan .dropmenu-action #menu-recurrent ",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.recurring.task').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan .postit-story:first .dropmenu-action .dropmenu, #window-id-sprintPlan .table-group .dropmenu-action .dropmenu:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.story.task').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-sprintPlan").find(".postit-story:first .dropmenu-action .dropmenu, .table-group .dropmenu-action .dropmenu:first").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-sprintPlan").find(".postit-story:first .dropmenu-action .dropmenu, .table-group .dropmenu-action .dropmenu:first").trigger('mouseleave');
    }
},
{
    element: "#window-id-sprintPlan .postit-task:first",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.task.postit').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan .postit-task:first .dropmenu-action .dropmenu, #window-id-sprintPlan .table-cell .dropmenu-action .dropmenu:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.task.menu').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-sprintPlan").find(".postit-task:first .dropmenu-action .dropmenu, .table-cell .dropmenu-action .dropmenu:first").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-sprintPlan").find(".postit-task:first .dropmenu-action .dropmenu, .table-cell .dropmenu-action .dropmenu:first").trigger('mouseleave');
    }
},
{
    element: "#window-id-sprintPlan .postit-task:first .mini-value, #window-id-sprintPlan .estimation :first",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.task.estimate').encodeAsJavaScript()}"
},
{
    element: "#window-toolbar > li.navigation-item.separator.button-activate",
    title: "${title}",
    placement: "bottom",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.sprint').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan .search .search-button",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.search').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan #s2id_selectOnSprintPlan",
    title: "${title}",
    placement: "bottom",
    content: "${message(code:'is.ui.guidedTour.sprintPlan.switch').encodeAsJavaScript()}"
}
