(function($) {
    jQuery.extend($.icescrum, {
                postit:{
                    updatePosition:function(selector, object, position, container) {
                        if (object.index() < position - 1) {
                            object.insertAfter($(selector, container).get(position - 1));
                        } else if (object.index() > position - 1) {
                            object.insertBefore($(selector, container).get(position - 1));
                        }
                    },

                    updateRankAndVersion:function(selector, container, oldRank, newRank, elemid) {
                        var rows = $(selector, container);
                        function updateRow(row, newRank) {
                            if(elemid == null || row.data('elemid') != elemid) {
                                row.data('rank', newRank);
                                $('div[name=rank]', row).text(newRank);
                                row.attr('version', parseInt(row.attr('version')) + 1);
                            }
                        }
                        if(newRank != null) {
                            // Update
                            if(oldRank != null) {
                                if(newRank > oldRank) {
                                    rows.each(function() {
                                        var rank = parseInt($(this).data('rank'));
                                        if(oldRank < rank && rank <= newRank) {
                                            updateRow($(this), rank - 1);
                                        }
                                    });
                                } else {
                                    rows.each(function() {
                                        var rank = parseInt($(this).data('rank'));
                                        if(newRank <= rank && rank < oldRank) {
                                            updateRow($(this), rank + 1);
                                        }
                                    });
                                }
                            }
                            // Insert
                            else {
                                rows.each(function() {
                                    var rank = parseInt($(this).data('rank'));
                                    if(rank >= newRank) {
                                        updateRow($(this), rank + 1);
                                    }
                                });
                            }
                        }
                        else {
                            // Delete
                            rows.each(function() {
                                var rank = parseInt($(this).data('rank'));
                                if(rank > oldRank) {
                                    updateRow($(this), rank - 1);
                                }
                            });
                        }
                    },

                    id:function(object) {
                        if ($(object).hasClass('postit') || $(object).hasClass('postit-rect')) {
                            var elem = $(object).data('elemid');
                            if (elem) {
                                return elem;
                            } else {
                                return false;
                            }
                        }
                        return false;
                    },

                    ids:function(object, idParam) {
                        if ($(object).hasClass('postit') || $(object).hasClass('postit-rect') || $(object).hasClass('table-line') || $(object).hasClass('identifiable')) {
                            var _idParam = idParam ? idParam : 'id';
                            var ids = [];
                            $.each(object, function(key, val) {
                                var elem = $(this).data('elemid');
                                if (elem) {
                                    ids.push(_idParam + '=' + elem);
                                }
                            });
                            return ids.join('&');
                        }
                        return false;
                    }
                }
            });
})(jQuery);