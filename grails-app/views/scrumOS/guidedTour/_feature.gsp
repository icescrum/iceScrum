{
    element: "#window-title-bar-feature .title",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.feature.welcome').encodeAsJavaScript()}",
    onShow: function () {
        if (location.hash != '#feature') {
            return $.icescrum.openWindow('feature');
        }
    }
},
{
    element: "#window-id-feature #window-toolbar .button-add",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.feature.new').encodeAsJavaScript()}",
    onShown: function() {
        $('#window-id-feature').find("#window-toolbar .button-add").trigger('mouseenter');
    },
    onHide: function() {
        $('#window-id-feature').find("#window-toolbar .button-add").trigger('mouseleave');
    }
},
{
    element: "#window-id-feature #window-toolbar .button-delete",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.feature.delete').encodeAsJavaScript()}",
    onShown: function() {
        $('#window-id-feature').find("#window-toolbar .button-delete").trigger('mouseenter');
    },
    onHide: function() {
        $('#window-id-feature').find("#window-toolbar .button-delete").trigger('mouseleave');
    }
},
{
    element: "#window-id-feature #window-toolbar #menu-display-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.feature.viewType').encodeAsJavaScript()}",
    onShown: function() {
        $('#window-id-feature').find("#window-toolbar #menu-display-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $('#window-id-feature').find("#window-toolbar #menu-display-navigation-item a").trigger('mouseleave');
    }
},
{
    element: "#window-id-feature  #menu-chart-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.feature.chart').encodeAsJavaScript()}",
    onShown: function() {
        $("#menu-chart-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#menu-chart-navigation-item a").trigger('mouseleave');
    }
},
{
    element: "#window-id-feature  #menu-report-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.feature.publishas').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-feature").find("#menu-report-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-feature").find("#menu-report-navigation-item a").trigger('mouseleave');
    }
},
{
    element: "#window-content-feature .mini-value:first",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.feature.value').encodeAsJavaScript()}"
},
{
    element: "#window-content-feature  .text-state:first",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.feature.state').encodeAsJavaScript()}"
},
{
    element: "#window-content-feature .dropmenu:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.feature.menu').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-feature").find("#window-content-feature .dropmenu-action:first .dropmenu").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-feature").find("#window-content-feature .dropmenu-action:first .dropmenu").trigger('mouseleave');
    }
},
{
    element: "#window-content-feature  .postit-feature:first, #window-content-feature .table-cell-editable-selectui-rank:first",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.feature.order').encodeAsJavaScript()}"
},

{
    element: "#window-id-feature .search .search-button",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.feature.search').encodeAsJavaScript()}"
}