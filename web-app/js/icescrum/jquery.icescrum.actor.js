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
        actor: {

            data:[],
            bindings:[],
            config: {
                actors: { }
            },
            restUrl: function(){ return $.icescrum.o.baseUrlSpace + 'actor/'; },
            onSelectableStop:function(event, ui){
                var selectable = $('.window-content.ui-selectable');
                var container = $('#contextual-properties');

                var id = selectable.data('current');
                //no selection
                if (!id || id.length == 0){
                    $.icescrum.actor.createForm(false, container);
                }
                //multi selection
                else if (id.length > 1){
                    var el = $.template('tpl-multiple-actors', {actor:_.findWhere($.icescrum['actor'].data, {id:_.last(id)}), ids:id});
                    container.html(el);
                }
                //one selected
                else if (id.length == 1) {
                    $.icescrum.object.dataBinding.apply(container.parent(), [{
                        type:'actor',
                        tpl:'tpl-edit-actor',
                        watchedId:id[0],
                        watch:'item',
                        selector:'#contextual-properties'
                    }]);
                }
                //update container
                manageAccordion(container);
                container.accordion("option", "active", 0);
                attachOnDomUpdate(container);
            },
            createForm:function(template, container){
                container = container ? container : $('#contextual-properties');
                var el;
                if (template){
                    $.get($.icescrum.actor.restUrl()+'templateEntries', {'template':template}, function(data){
                        data.name = $('input[name="actor.name"]', container).val();
                        el = $.template('tpl-new-actor', {actor:data, template:template});
                        container.html(el);
                        manageAccordion(container);
                        attachOnDomUpdate(container);
                    });
                } else {
                    el = $.template('tpl-new-actor', {actor:{}, template:template});
                    container.html(el);
                    manageAccordion(container);
                    attachOnDomUpdate(container);
                }
                container.find('input:first:visible').focus();
            },
            afterSave:function(data){
                var selectable = $('.window-content.ui-selectable');
                selectable.find('div[data-elemid="'+data.id+'"]').addClass('ui-selected');
                var stop = selectable.selectableScroll( "option" , "stop");
                if (stop){
                    stop({target:selectable});
                }
            },




            //TODO remove at end of refactoring
            templates:{
                window:{
                    selector:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? 'div.postit-actor' : 'tr.table-line';
                    },
                    id:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? 'postit-actor-tmpl' : 'table-row-actor-tmpl';
                    },
                    view:function() {
                        return $.icescrum.getDefaultView() == 'postitsView' ? '#backlog-layout-window-actor' : '#actor-table';
                    },
                    remove:function(tmpl) {
                        $.icescrum.getDefaultView() == 'postitsView' ? $(tmpl.view+' .postit-actor[data-elemid=' + this.id + ']').remove() : $(tmpl.view+' .table-line[data-elemid=' + this.id + ']').remove();
                        if ($.icescrum.getDefaultView() == 'tableView') {
                            $('#actor-table').trigger("update");
                        }
                        $('#actors-size').html($(tmpl.view+' .postit-actor, '+tmpl.view+' .table-line').size());
                    },
                    window:'#window-content-actor',
                    afterTmpl:function(tmpl) {
                        if ($.icescrum.getDefaultView() == 'tableView') {
                            $('#actor-table').trigger("update");
                        }
                        $('#actors-size').html($(tmpl.view+' .postit-actor, '+tmpl.view+' .table-line').size());
                    }
                },
                widget:{
                    selector:'li.postit-row-actor',
                    id:'postit-row-actor-tmpl',
                    view:'#backlog-layout-widget-actor',
                    remove:function() {
                        $('.postit-row-actor[data-elemid=' + this.id + ']').remove();
                    },
                    window:'#widget-content-actor'
                }
            },

            add:function(template) {
                $.icescrum.addOrUpdate(this, $.icescrum.actor.templates[template], $.icescrum.actor._postRendering);
            },

            update:function(template) {
                $.icescrum.addOrUpdate(this, $.icescrum.actor.templates[template], $.icescrum.actor._postRendering);
            },

            remove:function(template) {
                var tmpl;
                tmpl = $.extend(tmpl, $.icescrum.actor.templates[template]);
                tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(this) : tmpl.selector;
                tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(this) : tmpl.view;
                $(this).each(function() {
                    tmpl.remove.apply(this,[tmpl]);
                });
                if ($(tmpl.selector, $(tmpl.view)).length == 0) {
                    $(tmpl.view).hide();
                    $(tmpl.window + ' .box-blank').show();
                }
            },

            _postRendering:function(tmpl, newObject, container) {
                if (this.totalAttachments == undefined || !this.totalAttachments) {
                    newObject.find('.postit-attachment,.table-attachment').hide();
                }
                if (container.hasClass('ui-selectable')) {
                    newObject.addClass('ui-selectee');
                }
            }
        }
    });

})($);