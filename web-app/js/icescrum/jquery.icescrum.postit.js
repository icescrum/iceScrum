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