{
    element: "#window-title-bar-project .title",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.project.welcome').encodeAsJavaScript()}",
    onShow: function() {
        if (location.hash != '#project') {
            return $.icescrum.openWindow('project');
        }
    }
},
{
    element: "#window-id-project #menu-chart-navigation-item",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.project.chart').encodeAsJavaScript()}",
    onShown: function() {
        $("#menu-chart-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#menu-chart-navigation-item a").trigger('mouseleave');
    }
},
{
    element: "#window-id-project #menu-documents-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.project.documents').encodeAsJavaScript()}",
    onShown: function() {
        $("#menu-documents-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#menu-documents-navigation-item a").trigger('mouseleave');
    }
},
{
    element: "#window-id-project #menu-report-navigation-item",
    title: "${title}",
    placement: "bottom",
    content: "${message(code:'is.ui.guidedTour.project.publishas').encodeAsJavaScript()}"
},
{
    element: "#window-title-bar-project .help",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.project.help').encodeAsJavaScript()}"
},
{
    element: "#panel-chart-container",
    title: "${title}",
    content: "${message(code:'is.ui.guidedTour.project.projectindicators').encodeAsJavaScript()}"
},
{
    element: "#panel-activity",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.project.activities').encodeAsJavaScript()}"
},
{
    element: "#panel-description",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.project.description').encodeAsJavaScript()}"
},
{
    element: ".panel-vision:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.project.description.releaseVision').encodeAsJavaScript()}"
},
{
    element: ".panel-doneDefinition:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.project.description.current.definition').encodeAsJavaScript()}"
},
{
    element: ".panel-retrospective:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.project.description.current.retrospective').encodeAsJavaScript()}"
}