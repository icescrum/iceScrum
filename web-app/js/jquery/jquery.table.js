(function($) {

    var helper = {};

    $.table = {
        defaults: {
            'classNameFocus' : 'table-row-focus',
            'sortable':false,
            'sortableOptions': {}
        }
    };

    $.fn.extend({
                table: function(settings) {
                    settings = $.extend({}, $.table.defaults, settings);
                    $('.table-line .table-cell-checkbox', $(this)).live('hover', function() {
                        var elt = $(this);
                        if (elt.data("init")) {
                            return;
                        }
                        $(this).data("init", true);
                        var row = elt.parent();
                        var input = $('input', elt);
                        var td = $('td', row);

                        td.click(function(event) {
                            if ($(event.target).is('input,textarea,span')) {
                                return;
                            }
                            input.attr('checked', !input.attr('checked'));
                            input.attr('checked') ? row.addClass(settings.classNameFocus) : row.removeClass(settings.classNameFocus);
                        });

                        input.change(function() {
                            $(this).attr('checked') ? row.addClass(settings.classNameFocus) : row.removeClass(settings.classNameFocus);
                        });
                    });

                    $('tr.table-group').click(function(){
                        var self = $(this);
                        var trs = $('.table-group-' + self.data('elemid'));
                        var td = self.find('td');
                        trs.slideToggle('fast', function() {
                            if (trs.is(':visible')) {
                                td.removeClass('expand');
                                td.addClass('collapse');
                            } else {
                                td.removeClass('collapse');
                                td.addClass('expand');
                            }
                        });

                    });

                    $('th.table-cell-checkbox input').live('click', function() {
                        var elt = $(this);
                        if (elt.data("init")) {
                            return;
                        }
                        $(this).data("init", true);
                        if (elt.is(':checked')) {
                            elt.parents('table:first').find('td.table-cell-checkbox input:visible').attr('checked', 'checked');
                            $('tr.table-line:visible').addClass(settings.classNameFocus);
                        } else {
                            elt.parents('table:first').find('td.table-cell-checkbox input:visible').removeAttr('checked');
                            $('tr.table-line:visible').removeClass(settings.classNameFocus);
                        }
                    });

                    if (settings.sortable){
                        var table = $(this);
                        var sorts =table.find('th[data-sort-name]');
                        //case we have sort on some columns not all
                        if(sorts.length > 0){
                            settings.sortableOptions.headers = {};
                            $(this).find('th:not([data-sort-name])').each(function(){
                                settings.sortableOptions.headers[$(this).index()] = { sorter: false };
                            });
                        }
                         $(this).tablesorter(settings.sortableOptions);
                    }
                    return this;
                },
                updateTableSorter: function(timeout) {
                    var table = this;
                    timeout = (timeout != null) ? timeout : 20;
                    table.trigger("update");
                    setTimeout(function () {
                        table.trigger('sorton',[table[0].config.sortList]);
                    }, timeout);
                }
            });

})(jQuery);