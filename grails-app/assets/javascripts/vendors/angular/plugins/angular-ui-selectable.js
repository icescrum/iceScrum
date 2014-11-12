/*
 jQuery UI selectable plugin wrapper

 @param [ui-selectable] {object} Options to pass to $.fn.selectable() merged onto ui.config
 */
angular.module('ui.selectable', [])
    .value('uiSelectableConfig',{})
    .directive('uiSelectable', [
        'uiSelectableConfig', '$timeout',
        function(uiSelectableConfig, $timeout) {
            return {
                scope: {
                    items:"=uiSelectableList",
                    selectableConfig:"=uiSelectable"
                },
                link: function(scope, element) {
                    var selectedItems = [];

                    function combineCallbacks(first,second){
                        if(second && (typeof second === 'function')) {
                            return function(e, ui) {
                                first(e, ui, selectedItems);
                                second(e, ui, selectedItems);
                            };
                        }
                        return first;
                    }

                    function refreshSelectedList(){
                        selectedItems = element.find('.ui-selected').map(function () {
                            return {id:$(this).data('id')};
                            //return _.where(scope.items, {id: $(this).data('id') });
                        }).get();
                        selectedItems.length > 0 ? element.addClass('has-selected') : element.addClass('remove-selected');
                    }

                    var opts = {};

                    var callbacks = {
                        create:null,
                        selected:null,
                        selecting:null,
                        start:null,
                        stop:null,
                        unselected:null,
                        unselecting:null
                    };

                    angular.extend(opts, uiSelectableConfig);
                    if (scope.items) {

                        callbacks.stop = function(e, ui) {
                            angular.element(e.target).find('.open > a[data-toggle]').dropdown('toggle');
                            refreshSelectedList();
                            return true;
                        };

                        // When we add or remove elements, we need the selectable to 'refresh'
                        // so it can find the new/removed elements.
                        scope.$watch('items.length', function() {
                            // Timeout to let ng-repeat modify the DOM
                            $timeout(function() {
                                refreshSelectedList();
                                // ensure that the jquery-ui-selectable widget instance
                                // is still bound to the directive's element
                                if (!!element.data('ui-selectable')) {
                                    element.selectable('refresh');
                                }
                            });
                        });

                        scope.$watch('selectableConfig', function(newVal /*, oldVal */) {
                            // ensure that the jquery-ui-selectable widget instance
                            // is still bound to the directive's element
                            if (!!element.data('ui-selectable')) {
                                angular.forEach(newVal, function(value, key) {
                                    if(callbacks[key]) {
                                        if( key === 'stop' ){
                                            // call apply after stop
                                            value = combineCallbacks(
                                                value, function() { scope.$apply(); });
                                        }
                                        // wrap the callback
                                        value = combineCallbacks(callbacks[key], value);
                                    }

                                    element.selectable('option', key, value);
                                });
                            }
                        }, true);

                        angular.forEach(callbacks, function(value, key) {
                            opts[key] = combineCallbacks(value, opts[key]);
                        });

                    }

                    // Create selectable
                    element.selectable(opts);
                    element.parent().on('click', function(e){
                        //click every where in window-contet will remove selection
                        angular.element(this).find('.ui-selected').removeClass('ui-selected');
                        var s = element.selectable( "option" , "stop");
                        s(e);
                    });
                }
            };
        }
    ]);
