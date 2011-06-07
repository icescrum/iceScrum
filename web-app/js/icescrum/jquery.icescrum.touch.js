(function($) {
    jQuery.extend($.icescrum, {
                touchHandler:function(event) {
                    var touches = event.changedTouches,first = touches[0],type = '';
                    var types = {'touchstart': 'mousedown', 'touchmove': 'mousemove', 'touchend': 'mouseup'};
                    if (typeof(types[event.type]) == 'undefined')
                        return;
                    type = types[event.type];
                    if (event.type == 'touchstart') {
                        _t = first;
                    } else {
                        if (event.type == 'touchend') {
                            if (_prev == 'touchstart') {
                                type = 'click';
                            }
                        }
                        if (type != 'click' && _prev == 'touchstart') {
                            var se = document.createEvent('MouseEvent');
                            se.initMouseEvent('mousedown', true, true, window, 1, _t.screenX, _t.screenY, _t.clientX, _t.clientY, false, false, false, false, 0, null);
                            _t.target.dispatchEvent(se);
                        }
                        if (event.type != 'touchstart') {
                            var se = document.createEvent('MouseEvent');
                            se.initMouseEvent(type, true, true, window, 1, first.screenX, first.screenY, first.clientX, first.clientY, false, false, false, false, 0, null);
                            first.target.dispatchEvent(se);
                        }
                    }
                    _prev = event.type;
                    event.preventDefault();
                    return true;
                }
            });
})(jQuery);