/**
 * @preserve AngularJS PDF viewer directive using pdf.js.
 *
 * https://github.com/akrennmair/ng-pdfviewer
 *
 * MIT license
 */

angular.module('ngPDFViewer', []).directive('pdfviewer', ['$parse', function($parse) {
    var canvas = null;
    var instance_id = null;

    return {
        restrict: "E",
        template: '<canvas></canvas>',
        scope: {
            onPageLoad: '&',
            loadProgress: '&',
            src: '@',
            base64: '@',
            width: '@',
            id: '='
        },
        controller: ['$scope', '$element', function($scope, $element) {
            $scope.pageNum = 1;
            $scope.pdfDoc = null;
            $scope.scale = 1.0;
            $scope.MAX_ZOOM_OUT = 0.4;
            $scope.MAX_ZOOM_IN = 3.0;
            $scope.SCALE_STEP = 0.1;
            $scope.width = null;

            $scope.documentProgress = function(progressData) {
                if ($scope.loadProgress) {
                    $scope.loadProgress({state: "loading", loaded: progressData.loaded, total: progressData.total});
                }
            };

            $scope.loadPDF = function(path) {
                PDFJS.getDocument(path, null, null, $scope.documentProgress).then(function(_pdfDoc) {
                    $scope.pdfDoc = _pdfDoc;
                    $scope.renderPage($scope.pageNum, function(success) {
                        if ($scope.loadProgress) {
                            $scope.loadProgress({state: "finished", loaded: 0, total: 0});
                        }
                    });
                }, function(message, exception) {
                    if ($scope.loadProgress) {
                        $scope.loadProgress({state: "error", loaded: 0, total: 0});
                    }
                });
            };

            $scope.loadBase64PDF = function(base64) {
                PDFJS.getDocument(StringView.base64ToBytes(base64)).then(function(_pdfDoc) {
                    $scope.pdfDoc = _pdfDoc;
                    $scope.renderPage($scope.pageNum, function(success) {
                        if ($scope.loadProgress) {
                            $scope.loadProgress({state: "finished", loaded: 0, total: 0});
                        }
                    });
                }, function(message, exception) {
                    if ($scope.loadProgress) {
                        $scope.loadProgress({state: "error", loaded: 0, total: 0});
                    }
                });
            };

            $scope.renderPage = function(num, callback) {
                $scope.pdfDoc.getPage(num).then(function(page) {
                    var viewport;
                    if ($scope.width === 'page-fit') {
                        canvas.width = $element.parent().width();
                        if($scope.scale === 1){
                            $scope.scale = canvas.width / page.getViewport($scope.scale).width;
                        }
                        viewport = page.getViewport($scope.scale);
                        canvas.height = viewport.height;
                        canvas.width = viewport.width;
                        canvas.style.height = viewport.height;
                        canvas.style.width = viewport.width;
                    } else {
                        viewport = page.getViewport($scope.scale);
                    }
                    var ctx = canvas.getContext('2d');

                    canvas.height = viewport.height;
                    canvas.width = viewport.width;

                    page.render({canvasContext: ctx, viewport: viewport}).promise.then(
                        function() {
                            if (callback) {
                                callback(true);
                            }
                            $scope.$apply(function() {
                                $scope.onPageLoad({page: $scope.pageNum, total: $scope.pdfDoc.numPages});
                            });
                        },
                        function() {
                            if (callback) {
                                callback(false);
                            }
                        }
                    );
                });
            };
            $scope.$on('pdfviewer.zoomIn', function(evt, id) {
                if (id !== instance_id) {
                    return;
                }

                if ($scope.scale < $scope.MAX_ZOOM_IN) {
                    $scope.scale += $scope.SCALE_STEP;
                    $scope.renderPage($scope.pageNum);
                }
            });

            $scope.$on('pdfviewer.zoomOut', function(evt, id) {
                if (id !== instance_id) {
                    return;
                }

                if ($scope.scale > $scope.MAX_ZOOM_OUT) {
                    $scope.scale -= $scope.SCALE_STEP;
                    $scope.renderPage($scope.pageNum);
                }
            });

            $scope.$on('pdfviewer.zoomReset', function(evt, id) {
                if (id !== instance_id) {
                    return;
                }

                $scope.scale = 1.0;
                $scope.renderPage($scope.pageNum);
            });

            $scope.$on('pdfviewer.nextPage', function(evt, id) {
                if (id !== instance_id) {
                    return;
                }

                if ($scope.pageNum < $scope.pdfDoc.numPages) {
                    $scope.pageNum++;
                    $scope.renderPage($scope.pageNum);
                }
            });

            $scope.$on('pdfviewer.prevPage', function(evt, id) {
                if (id !== instance_id) {
                    return;
                }

                if ($scope.pageNum > 1) {
                    $scope.pageNum--;
                    $scope.renderPage($scope.pageNum);
                }
            });

            $scope.$on('pdfviewer.gotoPage', function(evt, id, page) {
                if (id !== instance_id) {
                    return;
                }

                if (page >= 1 && page <= $scope.pdfDoc.numPages) {
                    $scope.pageNum = page;
                    $scope.renderPage($scope.pageNum);
                }
            });

            $scope.$on('pdfviewer.reset', function(evt, id) {
                if (id !== instance_id) {
                    return;
                }

                $scope.pdfDoc = null;
                $scope.onPageLoad({page: -1, total: -1});
                $scope.scale = 1.0;
                $(instance_id).find('canvas').remove();
                canvas = $('<canvas></canvas>')[0];
                $(instance_id).append(canvas);
            });
        }],
        link: function(scope, iElement, iAttr) {
            canvas = iElement.find('canvas')[0];
            instance_id = iAttr.id;

            iAttr.$observe('src', function(v) {
                if (v !== undefined && v !== null && v !== '') {
                    scope.pageNum = 1;
                    scope.loadPDF(scope.src);
                }
            });
            iAttr.$observe('base64', function(v) {
                if (v !== undefined && v !== null && v !== '') {
                    scope.pageNum = 1;
                    scope.loadBase64PDF(scope.base64);
                }
            });
        }
    };
}]).service("PDFViewerService", ['$rootScope', function($rootScope) {

    var svc = {};
    svc.nextPage = function() {
        $rootScope.$broadcast('pdfviewer.nextPage');
    };

    svc.prevPage = function() {
        $rootScope.$broadcast('pdfviewer.prevPage');
    };

    svc.Instance = function(id) {
        var instance_id = id;

        return {
            prevPage: function() {
                $rootScope.$broadcast('pdfviewer.prevPage', instance_id);
            },
            nextPage: function() {
                $rootScope.$broadcast('pdfviewer.nextPage', instance_id);
            },
            gotoPage: function(page) {
                $rootScope.$broadcast('pdfviewer.gotoPage', instance_id, page);
            },
            zoomIn: function() {
                $rootScope.$broadcast('pdfviewer.zoomIn', instance_id);
            },
            zoomOut: function() {
                $rootScope.$broadcast('pdfviewer.zoomOut', instance_id);
            },
            zoomReset: function() {
                $rootScope.$broadcast('pdfviewer.zoomReset', instance_id);
            },
            reset: function() {
                $rootScope.$broadcast('pdfviewer.reset', instance_id);
            }
        };
    };

    return svc;
}]);