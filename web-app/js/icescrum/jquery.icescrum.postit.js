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

                    updateRankAndVersion:function(selector, container, oldPosition, position) {
                        var wantedIndex = position ? position - 1 : null;
                        var oldIndex = oldPosition ? oldPosition - 1 : null;
                        if(wantedIndex != null) {
                            // Update
                            if(oldIndex != null) {
                                if(wantedIndex > oldIndex) {
                                    $(selector, container).each(function(currentIndex, it) {
                                        if(oldIndex <= currentIndex && currentIndex < wantedIndex) {
                                            $('* [name="rank"]', it).text(currentIndex + 1);
                                            $(it).attr('version', parseInt($(it).attr('version')) + 1);
                                        }
                                    });
                                } else if (wantedIndex < oldIndex) {
                                    $(selector, container).each(function(currentIndex, it) {
                                        if(wantedIndex < currentIndex && currentIndex <= oldIndex) {
                                            $('* [name="rank"]', it).text(currentIndex + 1);
                                            $(it).attr('version', parseInt($(it).attr('version')) + 1);
                                        }
                                    });
                                }
                            }
                            // Insert
                            else {
                                $(selector, container).each(function(currentIndex, it) {
                                    if(currentIndex > wantedIndex) {
                                        $('* [name="rank"]', it).text(currentIndex + 1);
                                        $(it).attr('version', parseInt($(it).attr('version')) + 1);
                                    }
                                });
                            }
                        }
                        else {
                            // Delete
                            $(selector, container).each(function(currentIndex, it) {
                                debugger;
                                if(currentIndex >= oldIndex) {
                                    $('* [name="rank"]', it).text(currentIndex + 1);
                                    $(it).attr('version', parseInt($(it).attr('version')) + 1);
                                }
                            });
                        }
                    },

                    id:function(object) {
                        if ($(object).hasClass('postit') || $(object).hasClass('postit-rect')) {
                            var elem = $(object).attr('elemId');
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
                                var elem = $(this).attr('elemid');
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