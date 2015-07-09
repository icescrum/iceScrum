                {
                    element: "#window-title-bar-feature .title",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.feature.welcome').encodeAsJavaScript()}",
                    onShow: function (${tourName}) {
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
                    element: "#menu-chart-navigation-item",
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
                    element: "#menu-report-navigation-item",
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
                    element: "#window-id-feature .search .search-button",
                    title: "${title}",
                    placement: "left",
                    content: "${message(code:'is.ui.guidedTour.feature.search').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-feature .mini-value:first",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.feature.point').encodeAsJavaScript()}"
                },
                {
                    element: "#window-content-feature  .text-state:first",
                    title: "${title}",
                    placement: "right",
                    content: "${message(code:'is.ui.guidedTour.feature.estimated').encodeAsJavaScript()}"
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
                }