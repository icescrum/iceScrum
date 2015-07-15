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
    onPrev: function() {
        $("#menu-project .dropmenu-button").trigger('mouseleave');
    },
    onShown: function() {
        $("#menu-project .dropmenu-button").trigger('mouseenter');
    },
    onNext: function() {
        $("#menu-project .dropmenu-button").trigger('mouseenter');
    },
},
{
    element: "#my-projects",
    title: "${title}",
    content: "${message(code:'is.ui.guidedTour.welcome.menu.browse').encodeAsJavaScript()}",
    onNext: function() {
        $("#menu-project .dropmenu-button").trigger('mouseleave');
    },
},
{
    element: "#menu-project .dropmenu-button",
    title: "${title}",
    content: "${message(code:'is.ui.guidedTour.welcome.menu.create').encodeAsJavaScript()}",
    template:"${message(code:'is.ui.guidedTour.templateWithCreateProject').encodeAsJavaScript()}",
    onNext: function() {
        return $('.wizard').length || $.icescrum.openWizard();
    }
},
<g:include view="scrumOS/guidedTour/_createProject.gsp" model="[title: title]" />