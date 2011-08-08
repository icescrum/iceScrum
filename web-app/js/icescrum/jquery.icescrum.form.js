(function($) {
    jQuery.extend($.icescrum, {
                form:{
                    cancel:function() {
                        if (!confirm(jQuery.icescrum.o.cancelFormConfirmMessage)) {
                            return false;
                        } else {
                            location.hash = $("#cancelForm").attr('href');
                            return false;
                        }
                    },
                    reset:function(id,preserve) {
                        if (!preserve){
                            preserve = [];
                        }
                        $(':input', id)
                                .not(':button, :submit, :reset, :hidden')
                                .val('')
                                .removeAttr('checked')
                                .removeAttr('selected');
                        $('.is-multifiles-checkbox').remove();
                        $('select', id).each(function() {
                            if (this.id.indexOf('rank') > -1) {
                                var nextRank = $(this).find('option').size() + 1;
                                $(this).selectmenu('add', nextRank, nextRank, true);
                            } else {
                                if ($.inArray(this.id,preserve) == -1){
                                    $(this).selectmenu('value', 0);
                                }
                            }
                        });

                    }
                }
            })
})(jQuery);