/*
 * Copyright (c) 2011 Kagilum SAS.
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

Object.byString = function(o, s) {
    s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
    s = s.replace(/^\./, '');           // strip a leading dot
    var a = s.split('.');
    while (a.length) {
        var n = a.shift();
        if (o != null && n in o) {
            o = o[n];
        } else {
            return;
        }
    }
    return o;
};

function propertiesUpdated(prev, now) {
    var changes = [];
    for (var prop in now) {
        if (!_.contains(['version', 'lastUpdated'], prop)){
            if (!prev || prev[prop] !== now[prop]) {
                if (typeof now[prop] == "object") {
                    var c = propertiesUpdated(prev[prop], now[prop]);
                    if (! _.isEmpty(c) )
                        changes.push(prop);
                } else {
                    changes.push(prop);
                }
            }
        }
    }
    return changes;
}

(function($) {
    _.templateSettings = {
        evaluate:    /\*\*#([\s\S]+?)\*\*/g,
        interpolate: /\*\*[^#\{]([\s\S]+?)[^\}]\*\*/g,
        escape:      /\*\*\*([\s\S]+?)\*\*\*/g
    };

    $.extend($.icescrum, { object:{} } );

    $.extend($.icescrum.object, {

        dataBinding:function(_settings){
            if (_settings.container){
                _settings.container = !(_settings.container instanceof Object) ? $(_settings.container) : _settings.container;
            }
            var settings = $.extend({}, $.icescrum[_settings.type].config[_settings.config], {container:this, watchedId:_settings.id?_settings.id:null}, _settings );
            var type = settings.type;
            //Remove old binding (didn't find another way)
            $.icescrum[type].bindings = _.filter($.icescrum[type].bindings, function(a){ return $.contains(document.documentElement, a.container); });
            $.icescrum[type].bindings.push(settings);

            if (!$.icescrum[type].initialized){
                $.icescrum[type].initialized = 'process';
                _.observe($.icescrum[type].data, 'create', function(item, index) {
                    _.each($.icescrum[type].bindings, function(settings){
                        if (settings.watch == 'items'){
                            $.icescrum.object.viewBinding.add.apply(settings,[type, item, index]);
                        }
                    });
                });
                _.observe($.icescrum[type].data, 'update', function(item, old_item, index) {
                    var properties = propertiesUpdated(item, old_item);
                    _.each($.icescrum[type].bindings, function(settings){
                        if (settings.watch == 'items'){
                            $.icescrum.object.viewBinding.update.apply(settings,[type, item, index]);
                        }
                        else if (settings.watch == 'item' && item.id == settings.watchedId){
                            $.icescrum.object.viewBinding.update.apply(settings,[type, item, index]);
                        }
                    });
                });
                _.observe($.icescrum[type].data, 'delete', function(item, index) {
                    _.each($.icescrum[type].bindings, function(settings){
                        if (settings.watch == 'items'){
                            $.icescrum.object.viewBinding['delete'].apply(settings,[type, item, index]);
                        }
                        else if (settings.watch == 'item' && item.id == settings.watchedId){
                            $.icescrum.object.viewBinding['delete'].apply(settings,[type, item, index]);
                        }
                    });
                });

                _.observe($.icescrum[type].data, function() {
                    _.each($.icescrum[type].bindings, function(settings){
                        if (settings.watch == 'array'){
                            $.icescrum.object.viewBinding.update.apply(settings,[type, $.icescrum[type].data]);
                        }
                    });
                });
                $.icescrum.object.fetchData(type, settings);
            } else {
                if (settings.watch == 'items'){
                    var data;
                    if (settings.filter) { // TODO shouldn't we check that filter is a function?
                        data = _.filter($.icescrum[type].data, function(item) {
                            return (settings.filter.apply($.icescrum[type],[item])) ? item : false; // TODO why item is returned? Isn't the applied filter enough?
                        });
                    } else {
                        data = $.icescrum[type].data;
                    }
                    if (settings.sort && settings.sortOn){
                        data = _.sortBy(data, function(item) {  return settings.sort.apply(settings,[item]); });
                    }
                    // TODO I don't know why but if a filter is applied, the ecmascript (I guess) reverse() method is used
                    // TODO whereas if no filter is applied, the observable one is called.
                    // TODO consequently, when no filter is applied and setting.reverse is true, the observable reverse call cause a callCreateSubscribers on all items
                    // TODO which calls the observe("create"...) on the top of this file, which calls an "add" for each item, which duplicates them visually (but not in the data)
                    data = settings.reverse ? data.reverse() : data;
                    var _highLight = settings.highlight;
                    settings.highlight = false;
                    _.each(data, function(item){
                        $.icescrum.object.viewBinding.add.apply(settings,[type, item]);
                    });
                    settings.highlight = _highLight;
                } else if(settings.watch == 'item'){
                    $.icescrum.object.viewBinding.update.apply(settings,[type, _.findWhere($.icescrum[type].data,{id:settings.watchedId})]);
                } else if (settings.watch == 'array'){
                    $.icescrum.object.viewBinding.add.apply(settings,[type, $.icescrum[type].data]);
                }
                if (settings.afterBinding){
                    settings.afterBinding.apply(settings.container,[settings]);
                }
            }
        },

        removeBinding:function(type,element,clean){
            var config = _.find($.icescrum[type].bindings, function(a){ return element[0] == a.container; });
            if (config){
                $.icescrum[type].bindings = _.filter($.icescrum[type].bindings, function(a){
                    return !(config.container == a.container);
                });
                $(config.container).find(config.selector).remove();
            }
            return config;
        },

        addOrUpdateToArray:function(type, item){
            //to tackle observable on each push
            var _indexItem;
            if (_.isArray(item)){
                var beenUpdated = [];
                _.each(item, function(element, index, arr){
                    _indexItem = _.indexOf($.icescrum[type].data, _.findWhere($.icescrum[type].data, { id: element.id } ));
                    if (_indexItem != -1){
                        $.icescrum[type].data[_indexItem] = element;
                        beenUpdated.push(element.id);
                    }
                });
                if (beenUpdated.length){
                    item = _.reject(item, function(element){ return _.contains(beenUpdated, element.id) });
                }
                if (item.length > 0){
                    $.icescrum[type].data.splice.apply($.icescrum[type].data, [$.icescrum[type].data.length, 0].concat(item));
                }
            }else{
                _indexItem = _.indexOf($.icescrum[type].data, _.findWhere($.icescrum[type].data, {id:item.id}));
                if (_indexItem != -1){
                    $.icescrum[type].data[_indexItem] = item;
                } else {
                    $.icescrum[type].data.push(item);
                }
            }
        },

        removeFromArray:function(type, item){
            var _indexItem = _.indexOf($.icescrum[type].data, _.findWhere($.icescrum[type].data, {id:item.id}));
            if (_indexItem != -1){
                $.icescrum[type].data.splice(_indexItem, 1);
            }
        },

        //settings of binding who init the fetchData
        fetchData:function(type, settings){
            $.get($.icescrum[type].restUrl()+'list',
                function(data){
                    $.icescrum.object.addOrUpdateToArray(type, data);
                    if (settings.afterBinding){
                        settings.afterBinding.apply(settings.container, [settings]);
                    }
                    $.icescrum[type].initialized = true;
                }
            );
        },

        viewBinding:{

            add:function(type, item, index){
                var data = {};
                var el = null;
                if (this.watch == 'items'){
                        var filtered = _.isFunction(this.filter) ? this.filter.apply($.icescrum[type],[item]) : this.filter;
                    if (this.tpl && _.isUndefined(filtered) || filtered){
                        data[type] = item;
                        el = $.template(this.tpl, data);
                        el = $(el).appendTo(this.container);
                        if(this.highlight && $.icescrum[type].initialized == true){
                            el.effect('highlight', {color: this.highlight != true ? 'blue' : null}, 1000);
                        }
                    }
                }
                else if (this.watch == 'array'){
                    data['list'] = item;
                    el = $.template(this.tpl, data);
                    el = $(el).appendTo(this.container);
                }
                if (el)
                    attachOnDomUpdate(el);
            },

            update:function(type, item, index){
                var oldElement;
                var filtered = _.isFunction(this.filter) ? this.filter.apply($.icescrum[type],[item]) : this.filter;
                if (this.watch == 'items'){
                    oldElement = $(this.container).find(this.selector+'[data-elemid='+item.id+']');
                } else if (this.watch == 'array'){
                    oldElement = $(this.container).find(this.selector);
                } else if (this.watch == 'item'){
                    oldElement = $(this.container).find(this.selector);
                }
                //filtered but not visible ? should be added
                if((_.isUndefined(filtered) || filtered) && oldElement.length == 0){
                    $.icescrum.object.viewBinding.add.apply(this,[type, item, index]);
                }
                //filtered and visible ? update!
                else if (_.isUndefined(filtered) || filtered) {
                    var focus = $(':focus:not(document)');
                    focus = focus.attr('id') ? (focus.attr('id').startsWith('s2id') ? focus.attr('data-focusable') : focus.attr('id')) : null;
                    var data = {};
                    data[this.watch == 'array' ? 'list' : type] = item;
                    var el = $.template(this.tpl, data);
                    if (this.watch == 'items'){
                        el = oldElement.replaceWithPush(el);
                    } else if (this.watch == 'array'){
                        el = oldElement.replaceWithPush(el);
                    } else if (this.watch == 'item'){
                        el = oldElement.html(el);
                    }
                    var $el = $(el);
                    if (oldElement.hasClass('ui-selected')){
                        $el.addClass('ui-selected');
                    }
                    attachOnDomUpdate(this.container);
                    if (focus && $(focus, this.container)){
                        if(focus.startsWith('s2id')){
                            $('#'+focus, this.container).find('input[data-focusable="'+focus+'"]').focus();
                        } else {
                            $('#'+focus, this.container).focus();
                        }
                    }
                }
                //not filtered and visible ? delete!
                else if(!filtered && (oldElement && oldElement.length)){
                    $.icescrum.object.viewBinding['delete'].apply(this,[type, item, index]);
                }
            },

            'delete':function(type, item){
                if (this.watch == 'items'){
                    $(this.container).find(this.selector+'[data-elemid='+item.id+']').remove();
                }
                else if (this.watch == 'item'){
                    $(this.container).find(this.selector).html("");
                }
            }
        }
    });
})($);

//TODO remove at and of refactoring
(function($) {
    $.extend($.icescrum, {

            addOrUpdate:function(object, _tmpl, after, append) {

                    // Encoding of pushed objects is disabled temporarily
                    // because it causes issues with HTML content (notes etc.)
                    // A manual decoding will be required for those elements
                    // object = $.icescrum.htmlEncodeJSON(object);

                    if ($.isFunction(_tmpl.constraintTmpl)) {
                        if (_tmpl.constraintTmpl.apply(object) == false) {
                            return false;
                        }
                    }

                    var tmpl;
                    tmpl = $.extend(tmpl, _tmpl);
                    tmpl.selector = $.isFunction(tmpl.selector) ? tmpl.selector.apply(object) : tmpl.selector;
                    tmpl.view = $.isFunction(tmpl.view) ? tmpl.view.apply(object) : tmpl.view;
                    tmpl.id = $.isFunction(tmpl.id) ? tmpl.id.apply(object) : tmpl.id;

                    if ($(tmpl.window + ' .box-blank:visible').length) {
                        $(tmpl.view).show();
                        $(tmpl.window + ' .box-blank').hide();
                    }

                    var container = $(tmpl.view);
                    var current = $(tmpl.selector + '[data-elemid=' + object.id + ']', container);
                    var beforeData = null;
                    if ($.isFunction(tmpl.beforeTmpl)) {
                        beforeData = tmpl.beforeTmpl.apply(object, [tmpl,container,current]);
                    }

                    if (current.length) {
                        $(tmpl.selector + '[data-elemid=' + object.id + ']', container).jqoteup('#' + tmpl.id, object);
                    }
                    else {
                        append ? container.jqoteapp('#' + tmpl.id, object) : container.jqotepre('#' + tmpl.id, object);
                    }
                    var newObject = $(tmpl.selector + '[data-elemid=' + object.id + ']', container);

                    if ($.isFunction(after)) {
                        after.apply(object, [tmpl,newObject,container]);
                    }
                    if ($.isFunction(tmpl.afterTmpl)) {
                        tmpl.afterTmpl.apply(object, [tmpl,container,newObject,beforeData]);
                    }

                    var elem = $(tmpl.selector + '[data-elemid=' + object.id + ']', container);
                    attachOnDomUpdate(elem);

                    return elem;
                }
            });
})($);