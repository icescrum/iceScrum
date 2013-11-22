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

                    checkUploading:function(xhr, element){
                        var form = element.parents('form:first');
                        if ($('.is-multifiles .is-progressbar .ui-progressbar-value:not(.ui-progressbar-value-error)').size()) {
                            $.icescrum.renderNotice($.icescrum.o.uploading, 'error');
                            return false;
                        } else {
                            form.addClass('updating');
                            return true;
                        }
                    },

                    reset:function(data, status, xhr, element) {
                        var form = element.parents('form:first');
                        form.removeClass('updating');
                        // TODO make it work with contenteditable for story description
                        $(':input', form)
                                .not('.preserve')
                                .not(':button, :submit, :reset, :hidden')
                                .val('')
                                .removeAttr('checked')
                                .removeAttr('selected');
                        // TODO make it work with contenteditable for story description
                        $(':input[data-default]', form).each(function() {
                            var $this = $(this);
                            $this.val($this.data('default'))
                        });
                        $(':input.selectallonce').each(function() {
                            var $this = $(this);
                            $this.one('click', function() {
                                $this.select();
                            });
                        });
                        $('.is-multifiles-checkbox').remove();
                        $('select:not(.preserve)', form).each(function() {
                            if (this.id.indexOf('rank') > -1) {
                                var nextRank = $(this).find('option').size() + 1;
                                $(this).selectmenu('add', nextRank, nextRank, true);
                            } else {
                                $(this).selectmenu('value', 0);
                                $(this).trigger('onchange');
                            }
                        });
                        if ($('#datepicker-startDate', form).size() > 0){
                            $.icescrum.updateStartDateDatePicker(data);
                        }
                        if ($('#datepicker-endDate', form).size() > 0){
                            if (data['class'] == "Release"){
                                $.icescrum.updateEndDateDatePicker(data, 90);
                            } else {
                                $.icescrum.updateEndDateDatePicker(data, $.icescrum.product.estimatedSprintsDuration);
                            }
                        }
                        $('ul.tagit', form).tagit("reset");
                        $("input:visible, textarea:visible", form).first().focus();
                    }
                }
            })
})(jQuery);