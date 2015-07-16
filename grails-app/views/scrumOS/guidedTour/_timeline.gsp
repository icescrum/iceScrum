{
    element: "#window-title-bar-timeline .title",
    title: "${title}",
    placement: "right",
    content: "${message(code: 'is.ui.guidedTour.timeline.welcome').encodeAsJavaScript()}",
    onShow: function() {
        if (location.hash != '#timeline') {
            return $.icescrum.openWindow('timeline');
        }
    }
},
{
    element: "#window-id-timeline #window-toolbar .button-add",
    title: "${title}",
    placement: "left",
    content: "${message(code: 'is.ui.guidedTour.timeline.new').encodeAsJavaScript()}"
},
{
    element: "#window-id-timeline .button-graph",
    title: "${title}",
    placement: "left",
    content: "${message(code: 'is.ui.guidedTour.timeline.chart').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-timeline").find("#window-toolbar .button-graph").trigger('mouseenter');
    },
    onHide:function() {
        $("#window-id-timeline").find("#window-toolbar .button-graph").trigger('mouseleave');
    }
},

{
    element: "#menu-documents-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code: 'is.ui.guidedTour.timeline.documents').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-timeline").find("#menu-documents-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-timeline").find("#menu-documents-navigation-item a").trigger('mouseleave');
    }
},
{
    element: "#menu-report-navigation-item",
    title: "${title}",
    placement: "left",
    content: "${message(code: 'is.ui.guidedTour.timeline.publishas').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-timeline").find("#menu-report-navigation-item a").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-timeline").find("#menu-report-navigation-item a").trigger('mouseleave');
    }
},
{
    element: ".tape-timeline-release:last",
    title: "${title}",
    placement: "left",
    content: "${message(code: 'is.ui.guidedTour.timeline.sprint').encodeAsJavaScript()}"
},
{
    element: ".timeline-event-label .dropmenu:last",
    title: "${title}",
    placement:"left",
    content: "${message(code: 'is.ui.guidedTour.timeline.update').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-timeline").find(".timeline-event-label .dropmenu:last .dropmenu-content").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-timeline").find(".timeline-event-label .dropmenu:last").trigger('mouseleave');
    }
},
{
    element: ".tape-timeline-release:last",
    title: "${title}",
    placement : "top",
    content: "${message(code: 'is.ui.guidedTour.timeline.detail').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-timeline").find(".tape-timeline-release:last").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-timeline").find(".tape-timeline-release:last").trigger('mouseleave');
    }
},
{
    element: ".tape-timeline-sprint:last",
    title: "${title}",
    placement : "left",
    content: "${message(code: 'is.ui.guidedTour.timeline.sprint.detail').encodeAsJavaScript()}",
    onShown: function() {
        $("#window-id-timeline").find(".tape-timeline-sprint:last").trigger('mouseenter');
    },
    onHide: function() {
        $("#window-id-timeline").find(".tape-timeline-sprint:last").trigger('mouseleave');
    }
}