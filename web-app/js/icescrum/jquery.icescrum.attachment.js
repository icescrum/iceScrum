/*
 * Copyright (c) 2014 Kagilum SAS.
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
(function($) {
    $.extend($.icescrum, {
        attachments: {
            templates: {
                toolbar: {
                    selector: 'li.attachment-line',
                    id: 'toolbar-line-attachment-tmpl',
                    view: function() {
                        return 'ul#' + this.attachmentable['class'] + '-attachments-' + this.attachmentable.id;
                    }
                }
            },

            replaceAll:function(template) {
                var tmpl = $.icescrum.attachments.templates[template];
                var view = $.isFunction(tmpl.view) ? tmpl.view.apply(this) : tmpl.view;
                var container = $(view);
                if (container.length > 0) {
                    var attachmentable = this.attachmentable;
                    var controllerName = this.controllerName;
                    // Remove all
                    $(tmpl.selector, container).each(function() {
                        $(this).remove();
                    });
                    // Add all
                    $(this.attachments).each(function () {
                        this.attachmentable = attachmentable; // hack to make dynamic view evaluation working in the context of each attachment
                        this.controllerName = controllerName;
                        $.icescrum.addOrUpdate(this, tmpl, $.icescrum.attachments._postRendering, true);
                    });
                }
            },

            _postRendering:function(tmpl, attachment) {
                var filenameSpan = $('.filename', attachment);
                var truncatedFilename = $.icescrum.truncate(filenameSpan.text(), 23);
                filenameSpan.text(truncatedFilename);
            }
        }
    })
})($);