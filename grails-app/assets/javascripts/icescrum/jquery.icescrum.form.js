(function($) {
    jQuery.extend($.icescrum, {
                form:{
                    //TODO change for dropzone
                    checkUploading:function(xhr, element){
                        var form = element.parents('form:first');
                        if ($('.is-multifiles .is-progressbar .ui-progressbar-value:not(.ui-progressbar-value-error)').size()) {
                            $.icescrum.renderNotice($.icescrum.o.uploading, 'error');
                            return false;
                        } else {
                            form.addClass('updating');
                            return true;
                        }
                    }
                }
            })
})(jQuery);