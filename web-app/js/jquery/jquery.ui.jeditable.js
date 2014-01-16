/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 * Damien Vitrac (damien@oocube.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
(function($){
    $.editable.addInputType('datepicker', {
        element: function(settings, original) {

            var input = jQuery('<input size=8 />');

            // Catch the blur event on month change
            settings.onblur = function(e) {
            };

            input.datepicker({
                        dateFormat: 'yy-mm-dd',
                        onSelect: function(dateText, inst) {
                            jQuery(this).parents("form").submit();
                        },
                        onClose: function(dateText, inst) {
                            jQuery(this).parents("form").submit();
                        }

                    });

            input.datepicker('option', 'showAnim', 'slide');

            jQuery(this).append(input);
            return (input);
        }
    });


    $.editable.addInputType('richarea', {
        element : $.editable.types.textarea.element,
        plugin  : function(settings, original) {
            settings.markitup.resizeHandle = false;
            $('textarea', this).markItUp(settings.markitup);
            settings.placeholder = '';
            $('textarea', this).css('height', '100px');
        }
    });


    $.editable.addInputType('selectui', {
        element : function(settings, original) {
            settings.onblur = 'ignore';
            var select = $('<select id="' + new Date().getTime() + '"/>');
            $(this).append(select);
            return(select);
        },
        content : function(data, settings, original) {
            /* If it is string assume it is json. */
            if (String == data.constructor) {
                eval('var json = ' + data);
            } else {
                /* Otherwise assume it is a hash already. */
                var json = data;
            }
            for (var key in json) {
                if (!json.hasOwnProperty(key)) {
                    continue;
                }
                if ('selected' == key) {
                    continue;
                }
                var option = $('<option />').attr('value', key).append($('<div/>').text(json[key]).html());
                $('select', this).append(option);
            }
            if ($(original).data('placeholder')) {
                $('select', this).prepend('<option></option>');
            }
            /* Loop option again to set selected. IE needed this... */
            $('select', this).children().each(function() {
                if ($(this).val() == json['selected'] ||
                        $(this).text() == $.trim(original.revert)) {
                    $(this).attr('selected', 'selected');
                }
            }
            );
        },
        plugin: function(settings, original) {
            var form = this;
            var select = $('select', form);
            var options = {
                minimumResultsForSearch: -1,
                containerCssClass: 'custom-select2-dropdown',
                dropdownCssClass: 'custom-select2-dropdown',
                width: 'element',
                openOnInit: true
            };
            $.extend(options, $(original).data());
            select.data(options);
            select.one("change select2-close select2-blur", function(){
                select.off();
                form.submit();
            });
            attachOnDomUpdate(form);
        }
    });

    $.editable.addInputType('autocompletable', {
        element : function(settings, original) {
            var input = $('<input data-autocompletable="true"/>');
            if (settings.width  != 'none') { input.width(settings.width);  }
            if (settings.height != 'none') { input.height(settings.height); }
            input.attr('autocomplete','off');
            $(this).append(input);
            return(input);
        }, plugin: function(settings, original) {
            var form = this;
            var input = $('input', form);
            input.data($(original).data());
            attachOnDomUpdate(form);
        }
    });

    $.editable.addInputType('atarea', {
        element : function(settings, original) {
            settings.onblur = 'ignore';
            var textarea = $('<textarea data-atable="true"/>');
            if (settings.rows) {
                textarea.attr('rows', settings.rows);
            } else if (settings.height != "none") {
                textarea.height(settings.height);
            }
            if (settings.cols) {
                textarea.attr('cols', settings.cols);
            } else if (settings.width != "none") {
                textarea.width(settings.width);
            }
            $(this).append(textarea);
            return(textarea);
        }, plugin: function(settings, original) {
            var form = this;
            var textarea = $('textarea', form);
            textarea.blur(function(e) {
                if (!$('.atwho-view-ul').is(':visible')) {
                    /* prevent double submit if submit was clicked */
                    t = setTimeout(function() {
                        form.submit();
                    }, 200);
                }
            });
            textarea.data($(original).data());
            attachOnDomUpdate(form);
        }
    });
})($);

var textHelper = {
    getValueFromText: function(textValue) {
        return $.icescrum.htmlDecode(textValue);
    },
    getValueFromInput: function(inputField) {
        return inputField.find('input').val();
    },
    data: function() {
        return function(textValue) {
            return $.editable.customTypeHelper.text.getValueFromText(textValue);
        };
    }
};

var selectUiHelper = {
    getValueFromText: function(textValue) {
        return $.icescrum.htmlDecode(textValue);
    },
    getValueFromInput: function(inputField) {
        return inputField.find('select').children('option:selected').text();
    },
    data: function(field) {
        var selectValuesData = field.data('editable-values').replace(/'/g, '"');
        var selectValues = $.parseJSON(selectValuesData);
        return function (value) {
            return $.extend(selectValues, {'selected': value});
        };
    }
};

var textAreaHelper = {
    getValueFromText: function(textValue) {
        return $.icescrum.htmlDecode(textValue.replace(/<br[\s\/]?>/gi, '\n'));
    },
    getValueFromInput: function(inputField) {
        return inputField.find('textarea').val();
    },
    data: function() {
        return function (textValue) {
            return $.editable.customTypeHelper.textarea.getValueFromText(textValue);
        };
    }
};

var richAreaHelper = {
    getValueFromText: function(textValue) {
        return textValue;
    },
    getValueFromInput: function(inputField) {
        return inputField.find('textarea').val();
    },
    data: function() {
        return function (textValue) {
            return $.editable.customTypeHelper.richarea.getValueFromText(textValue);
        };
    },
    specificOptions: {
        markitup: textileSettings
    }
 };

$.editable.customTypeHelper = {
    text: textHelper,
    autocompletable: textHelper,
    selectui: selectUiHelper,
    textarea: textAreaHelper,
    atarea: textAreaHelper,
    richarea: richAreaHelper
};
