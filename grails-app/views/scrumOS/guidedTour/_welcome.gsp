{
    element: "#main",
    title: "${title}",
    placement: "top",
    content: "${message(code:'is.ui.guidedTour.welcome.welcome', args:[user?.firstName?.encodeAsJavaScript() + ' ' + user?.lastName?.encodeAsJavaScript()]).encodeAsJavaScript()}"
},
{
    element: "#navigation",
    title: "${title}",
    placement: "bottom",
    content: "${message(code:'is.ui.guidedTour.welcome.navigation')}"
},
{
    element: "#main",
    title: "${title}",
    placement: "top",
    content: "${message(code:'is.ui.guidedTour.welcome.main')}"
},
{
    element: "#local",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.welcome.widget')}"
},
{
    element: "#navigation-avatar",
    title:  "${title}",
    placement: "left",
    content:  "${message(code:'is.ui.guidedTour.welcome.logged').encodeAsJavaScript()}"
},
{
    element: "#is-logo",
    title:  "${title}",
    content:  "${message(code:'is.ui.guidedTour.welcome.islogo').encodeAsJavaScript()}"
},
{
    element: "#menu-project .dropmenu-button",
    title: "${title}",
    content: "${message(code:'is.ui.guidedTour.welcome.menu').encodeAsJavaScript()}",
    onShown: function() {
        $("#menu-project .dropmenu-button").trigger('mouseenter');
    },
    onHide: function() {
        $("#menu-project .dropmenu-button").trigger('mouseleave');
    }
}