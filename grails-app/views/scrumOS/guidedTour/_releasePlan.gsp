{
    element: "#window-title-bar-releasePlan .title",
    title: "${title}",
    placement: "right",
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
    element: "#widget-title-bar-backlog",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.releasePlan.backlog').encodeAsJavaScript()}"
},
{
    element: "#window-id-releasePlan .postit-rect:first",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.releasePlan.story').encodeAsJavaScript()}"
},
{
    element: "#window-id-releasePlan #window-content-releasePlan  .event-overflow .event-container .dropmenu:first",
    title: "${title}",
    placement: "right",
    content: "${message(code:'is.ui.guidedTour.releasePlan.sprint').encodeAsJavaScript()}"
},
{
    element: "#window-id-releasePlan #menu-postit-sprint-9",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.releasePlan.close.sprint').encodeAsJavaScript()}"
},
{
    element: "#window-id-releasePlan #s2id_selectOnReleasePlan",
    title: "${title}",
    placement: "bottom",
    content: "${message(code:'is.ui.guidedTour.releasePlan.switch').encodeAsJavaScript()}"
}
