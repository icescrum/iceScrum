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

function propertiesUpdated(a, b) {
    var diff = function(a, b, c) {
        c = {};
        $.each([a, b], function(index, obj) {
            for (prop in obj) {
                if (obj.hasOwnProperty(prop)) {
                    if (!_.contains(['lastUpdated','version'], prop)){
                        if (prop.startsWith('_')){
                            var realProp = prop.substr(1);
                            c[realProp]  = [a[prop], {}];
                        }
                        else if (typeof obj[prop] === "object" && obj[prop] !== null) {
                            c[prop] = diff(a[prop], b[prop], c);
                        }
                        else {
                            if(a === undefined || a == null) a = {};
                            if(b === undefined || b == null) b = {};
                            else if (a[prop] !== b[prop]) {
                                c[prop]  = [a[prop], b[prop]];
                            }
                        }
                    }
                }
            }
        });
        return _.compactObject(c);
    };
    var res = diff(a, b);
    var properties = [];
    for (prop in res) {
        if (res.hasOwnProperty(prop) && !_.isEmpty(res[prop])){
            properties.push(prop);
        }
    }
    return properties;
}

(function($) {
    var cache = {};
    $.template = function(name, data){
        var template = cache[name];
        if (!template){
            var $template = $('#tpl-' + name);
            template = $template.html();
            //also cache children templates
            $(template).find('[id^="tpl"]').each(function(){
                $.template(this.id, false);
            });
            cache[name] = template;
            $template.remove();
        }
        try {
            return data !== false ? _.template(cache[name], data || {}).replace(/tpl-/g, '') : null;
        } catch(e){
            console.log(e);
        }
    };

    $.extend($.icescrum, { object:{} } );
    $.extend($.icescrum.object, {

        dataBinding:function(_settings){

            if (_settings.container){
                _settings.container = !(_settings.container instanceof Object) ? $(_settings.container) : _settings.container;
            }
            //for case where there is only on property to listen force to be an array
            _settings.property = _settings.property ? _settings.property.replace(/\s/g,'').split(',') : null;
            if(_settings.property && !_.isArray(_settings.property)){  _settings.property = [_settings.property]; }

            var settings = $.extend({}, $.icescrum[_settings.type].config[_settings.config], {
                container: this,
                tpl: this.tpl ? this.tpl : this.id,
                id: null,
                property: null
            }, _settings );
            var obj = $.icescrum[settings.type];

            //Remove old binding (didn't find another way)
            obj.bindings = _.filter(obj.bindings, function(a){
                return $.contains(document.documentElement, a.container);
            });
            obj.bindings.push(settings);

            if (!obj.initialized){
                obj.initialized = "progress";
                _.observe(obj.data, 'create', function(item, index) {
                    _.each(obj.bindings, function(settings){
                        $.icescrum.object.viewBinding.add.apply(settings,[$.extend({}, obj.proxyProperties, item), index, obj.initialized === true]);
                    });
                });
                _.observe(obj.data, 'update', function(item, old_item, index) {
                    var properties = propertiesUpdated(item, old_item);
                    _.each(obj.bindings, function(settings){
                        //look for items or size OR look for specific item OR look for specific item & property
                        if (settings.watch == 'size' || settings.watch == 'items' || settings.watch == 'item' && item.id == settings.id && !settings.property || settings.property && _.intersection(properties, settings.property).length > 0 && item.id == settings.id){
                            $.icescrum.object.viewBinding.update.apply(settings,[$.extend({}, obj.proxyProperties, item), index]);
                        }
                    });
                });
                _.observe(obj.data, 'delete', function(item, index) {
                    _.each(obj.bindings, function(settings){
                        //case look for items or specific item
                        if (settings.watch == 'items' || settings.watch == 'item' && item.id == settings.id){
                            $.icescrum.object.viewBinding['delete'].apply(settings,[item, index]);
                        }
                    });
                });
                _.observe(obj.data, function() {
                    _.each(obj.bindings, function(settings){
                        if (settings.watch == 'size'){
                            $.icescrum.object.viewBinding.update.apply(settings,[obj.data]);
                        }
                    });
                });
                $.icescrum.object.fetchData(settings);

            } else {
                var data;
                if (settings.property || settings.watch == 'item'){
                    data = $.extend({}, obj.proxyProperties, _.findWhere(obj.data, { id:settings.id }));
                    //init proxy property
                    if (!_.isEmpty(data)){
                        _.each(settings.property, function(property){
                            if (obj.proxyProperties.hasOwnProperty(property)){
                                data[property]();
                            }
                        });
                    }
                    $.icescrum.object.viewBinding.add.apply(settings, [data]);
                } else if (settings.watch == 'size'){
                    $.icescrum.object.viewBinding.add.apply(settings, [obj.data]);
                }
                else if (settings.watch == 'items'){
                    data = settings.filter ? _.filter(obj.data, settings.filter) : obj.data;
                    data = settings.sort && settings.sortOn ? _.sortBy(data, function(item) {  return settings.sort.apply(settings,[item]); }) : data;
                    data = settings.reverse ? data.reverse() : data;
                    _.each(data, function(item, index){
                        $.icescrum.object.viewBinding.add.apply(settings,[$.extend({}, obj.proxyProperties, item), index, true]);
                    });
                }
            }
            //do we have to do perform something after binding?
            if (settings.after){
                settings.after.apply(settings.container,[settings]);
            }
        },

        removeBinding:function(type, element){
            var settings = _.find($.icescrum[type].bindings, function(a){ return element[0] == a.container; });
            if (settings){
                $.icescrum[type].bindings = _.filter($.icescrum[type].bindings, function(a){
                    return !(settings.container == a.container);
                });
                if (settings.watch == 'items'){
                    $(settings.container).html("");
                } else {
                    $(settings.container).remove();
                }
            }
            return settings;
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
        fetchData:function(settings){
            $.get($.icescrum[settings.type].restUrl(),
                function(data){
                    $.icescrum.object.addOrUpdateToArray(settings.type, data);
                    if (settings.after){
                        settings.after.apply(settings.container, [settings]);
                    }
                    $.icescrum[settings.type].initialized = true;
                }
            );
        },

        viewBinding:{

            add:function(item, index, noHighlight){
                var data = {}, el, filtered;
                filtered = this.filter ? _.filter([item], this.filter).length == 1 : true;
                if (filtered){
                    data[this.watch == 'size' ? 'list' : (this.object ? this.object : this.type)] = item;
                    if (!_.isEmpty(data)){
                        el = $.template(this.tpl, data);
                        el = $(el).appendTo(this.container);
                        if (el){
//                            attachOnDomUpdate($(this.container));
                            if(!noHighlight && this.highlight && $.icescrum[this.type].initialized == true){
                                el.effect('highlight', {color: this.highlight != true ? 'blue' : null}, 1000);
                            }
                        }
                    }
                }
            },

            update:function(item, index){
                var filtered, oldElement, el, data;
                filtered = this.filter ? _.filter([item], this.filter).length == 1 : true;
                //grab current view in dom
                if (this.watch == 'items'){
                    oldElement = $(this.container).find('> [data-elemid='+item.id+']');
                }
                else if (this.watch == 'item' || this.property.length > 0){
                    oldElement = $(this.container);
                }
                else if (this.watch == 'size'){
                    oldElement = $(this.container).find(this.selector);
                }
                //filtered but not visible ? should be added
                if(filtered){
                    if (oldElement.length == 0){
                        $.icescrum.object.viewBinding.add.apply(this,[this.type, item, index]);
                    } else {
                        //get current focus
                        var focus = $(':focus:not(document)');
                        focus = { id : focus.attr('id') ? (focus.attr('id').startsWith('s2id') ? focus.attr('data-focusable') : focus.attr('id')) : null };
                        if ($('#'+focus.id).is('input, textarea')){
                            var $focusCursor = $('#'+focus.id);
                            focus.start = $focusCursor[0].selectionStart;
                            focus.end = $focusCursor[0].selectionEnd;
                        }

                        //setup data for template
                        data = {};
                        data[this.watch == 'size' ? 'list' : (this.object ? this.object : this.type)] = item;
                        //generate new view
                        el = $.template(this.tpl, data);
                        if (el){
                            //find correct way to update dom
                            if (this.watch == 'items' || this.watch == 'size'){
                                el = oldElement.replaceWithPush(el);
                            }
                            else if (this.watch == 'item' || this.property.length > 0){
                                el = oldElement.html(el);
                            }
                            if (oldElement.hasClass('ui-selected')){
                                $(el).addClass('ui-selected');
                            }
                            //attach UI events
//                            attachOnDomUpdate(this.container);
                        }
                        //restore focus
                        if (focus.id && $('#'+focus.id, this.container).length > 0){
                            var $newFocus = $('#'+focus.id, this.container);
                            if(focus.id.startsWith('s2id')){
                                $newFocus.find('input[data-focusable="'+focus.id+'"]').focus();
                            } else {
                                $newFocus.focus();
                                if (focus.start != undefined){
                                    $newFocus[0].setSelectionRange(focus.start, focus.end);
                                }
                            }
                        }
                    }
                } else if(!filtered && (oldElement && oldElement.length)){
                    $.icescrum.object.viewBinding['delete'].apply(this,[this.type, item, index]);
                }
            },

            'delete':function(item){
                if (this.watch == 'items'){
                    $(this.container).find('> [data-elemid='+item.id+']').remove();
                }
                else if (this.watch == 'item'){
                    this.selector ? $(this.container).find(this.selector).html("") : $(this.container).remove();
                }
            }
        }
    });
})($);