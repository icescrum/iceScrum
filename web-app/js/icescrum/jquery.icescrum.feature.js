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
        feature:{
            templates:{
                features:{
                    selector:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? 'div.postit-feature' : 'tr.table-line';
                    },
                    id:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? 'postit-feature-tmpl' : 'table-row-feature-tmpl';
                    },
                    view:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? '#backlog-layout-window-feature' : '#feature-table';
                    },
                    remove:function(tmpl) {
                        if ($.icescrum.getDefaultView() == 'tableView') {
                            var tableline = $(tmpl.view+' .table-line[data-elemid=' + this.id + ']');
                            var oldRank = tableline.data('rank');
                            tableline.remove();
                            $.icescrum.postit.updateRankAndVersion(tmpl.selector, tmpl.view, oldRank);
                            $('#feature-table').trigger("update");
                        }else{
                            $(tmpl.view+' '+'.postit-feature[data-elemid=' + this.id + ']').remove();
                        }
                        $('#features-size').html($(tmpl.view+' .postit-feature, '+tmpl.view+' .table-line').size());
                    },
                    window:'#window-content-feature',
                    afterTmpl:function(tmpl, container, newObject) {
                        if ($.icescrum.getDefaultView() == 'tableView') {
                            $('div[name=rank]', $(newObject)).text(this.rank);
                            if(this.oldRank != this.rank) {
                                $.icescrum.postit.updateRankAndVersion(tmpl.selector, tmpl.view, this.oldRank, this.rank, this.id);
                            }
                            $('#feature-table').updateTableSorter();
                        }else{
                            if (this.rank && this.rank != 0) {
                                $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                            }
                        }
                        $('#features-size').html($(tmpl.view+' .postit-feature, '+tmpl.view+' .table-line').size());
                    },
                    beforeTmpl:function(tmpl,container,current) {
                        this.oldRank = current.data('rank');
                    }
                },
                widget:{
                    selector:'.postit-row-feature',
                    id:'postit-row-feature-tmpl',
                    view:'#backlog-layout-widget-feature',
                    remove:function(tmpl) {
                        $(tmpl.view+' '+'.postit-row-feature[data-elemid=' + this.id + ']').remove();
                    },
                    window:'#widget-content-feature',
                    afterTmpl:function(tmpl, container, newObject) {
                        if (this.rank && this.rank != 0) {
                            $.icescrum.postit.updatePosition(tmpl.selector, newObject, this.rank, container);
                        }
                    }
                }
            },

            add:function(template) {
                $(this).each(function() {
                    $.icescrum.addOrUpdate(this, $.icescrum.feature.templates[template], $.icescrum.feature._postRendering);
                });
            },

            update:function(template) {
                var feature = this;
                $(feature.stories).each(function() {
                    $('div.postit-story[data-elemid=' + this.id + '] .postit-layout').removeClass().addClass('postit-layout postit-' + feature.color);
                    $('li.postit-row-story[data-elemid=' + this.id + '] .postit-icon').removeClass().addClass('postit-icon postit-icon-' + feature.color);
                });
                $('#detail-feature-' + feature.id + ' .line-right').replaceWith('<td class="line-right"><span class="postit-icon postit-icon-' + feature.color + '" title="' + feature.name + '"></span>' + feature.name + '</td>');
                if (template){
                    $.icescrum.addOrUpdate(feature, $.icescrum.feature.templates[template], $.icescrum.feature._postRendering);
                }
            },

            remove:function(template) {
                var tmpl;
                tmpl = $.extend(tmpl, $.icescrum.feature.templates[template]);
                tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(this) : tmpl.selector;
                tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(this) : tmpl.view;
                $(this).each(function() {
                    tmpl.remove.apply(this,[tmpl]);
                });
                if (!tmpl.noblank) {
                    if ($(tmpl.selector, $(tmpl.view)).length == 0) {
                        $(tmpl.view).hide();
                        $(tmpl.window + ' .box-blank').show();
                    }
                }
            },

            _postRendering:function(tmpl, newObject, container) {
                if (this.totalAttachments == undefined || !this.totalAttachments) {
                    newObject.find('.postit-attachment,.table-attachment').hide()
                }
                if (container.hasClass('ui-selectable')) {
                    newObject.addClass('ui-selectee');
                }
            }
        }
    });

})($);