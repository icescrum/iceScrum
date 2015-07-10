{
    element: "#window-title-bar-sprintPlan .title",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.sprintplan.welcome').encodeAsJavaScript()}",
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
    content: "${message(code:'is.ui.guidedTour.sprintplan.new').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan  .button-filter",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintplan.alltask').encodeAsJavaScript()}",
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
    content: "${message(code:'is.ui.guidedTour.sprintplan.close').encodeAsJavaScript()}"
},
{
    element: "#window-id-sprintPlan  #menu-documents-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.sprintplan.documents').encodeAsJavaScript()}",
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
    content: "${message(code:'is.ui.guidedTour.sprintplan.chart').encodeAsJavaScript()}",
    onShown: function() {
        $("#menu-chart-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#menu-chart-navigation-item a").trigger('mouseleave');
    }
},
{
    element: ".dropmenu-action .dropmenu:first",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.sprintplan.urgent.task').encodeAsJavaScript()}"
},
{
    element: ".dropmenu-action .dropmenu:last",
    title: "${title}",
    placement: "right",
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