{
    element: "#window-title-bar-releasePlan .title",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.releasePlan.welcome').encodeAsJavaScript()}",
    onShow: function (${tourName}) {
        if (location.hash != '#releasePlan') {
            return $.icescrum.openWindow('releasePlan');
        }
    }
},
{
    element: "#window-id-releasePlan .button-add",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.releasePlan.new').encodeAsJavaScript()}"
},
{
    element: "#local",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.releasePlan.backlog').encodeAsJavaScript()}"
},
{
    element: ".postit-rect:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.releasePlan.story').encodeAsJavaScript()}"
},
{
    element: "#window-content-releasePlan  .event-overflow .event-container .dropmenu:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.releasePlan.sprint').encodeAsJavaScript()}",
    onShow:function(tour){
        $("#window-toolbar").find("#window-content-releasePlan  .event-overflow .event-container .dropmenu:first").trigger('mouseenter');
    } //pb fonctionne que quand pas de projet
},
{
    element: "#menu-postit-sprint-9",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.releasePlan.close.sprint').encodeAsJavaScript()}"
}
