/*
 * Version: MPL 1.1
 *
 * "The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations under
 * the License.
 *
 * The Original Code is ICEfaces 1.5 open source software code, released
 * November 5, 2006. The Initial Developer of the Original Code is ICEsoft
 * Technologies Canada, Corp. Portions created by ICEsoft are Copyright (C)
 * 2004-2009 ICEsoft Technologies Canada, Corp. All Rights Reserved.
 *
 * Contributor(s): Vincent Barrier.
 *
*/

(function($) {
	$.push = {
		version : 0.1,
		groups : {},
		pushIds : {},
		listenToGroup : function(groupName, callback, id) {
            var registrations = $.push.groups[groupName];
            id = id ? id : "not set";
            if (registrations) {
                if( callback ){
                  for (var i = 0; i < registrations.length; i++) {
                      if (registrations[i] != null && ((registrations[i][2] != null && registrations[i][2] == id) || (registrations[i][0] == callback))){
                        console.log('already listening notifications [group: '+groupName+', callbackID: '+id+']');
                        return;
                      }
                  }
                }
            }

			var pushId = ice.push.createPushId();
			if (this.groups[groupName] == null) {
				this.groups[groupName] = new Array();
			}
			this.groups[groupName].push( [ callback, pushId, id ]);
			this.pushIds[pushId] = [groupName,callback];
			ice.push.addGroupMember(groupName, pushId);
			ice.push.register( [ pushId ], callback);
            console.log('added listening notifications [group: '+groupName+', callbackID: '+id+']');
		},

		stopListeningToGroup : function(groupName, callback, id) {
			var registrations = this.groups[groupName];
            id = id ? id : "not set";
			if (registrations) {
				//if callback passed, just remove registrations for this callback
				if( callback ){
					for ( var i = 0; i < registrations.length; i++) {
                        if (registrations[i] != null && ((registrations[i][2] != null && registrations[i][2] == id) || (registrations[i][0] == callback))) {
							ice.push.removeGroupMember(groupName,registrations[i][1]);
                            console.log('removed listening notifications [group: '+groupName+', callbackID: '+id+']');
							$.push.pushIds[registrations[i][1]] = null;
							registrations[i] = null;
							if (registrations.length == 0){
                                this.groups[groupName] = null;
                                console.log('removed listening notifications [group: '+groupName+', callbackID: '+id+']');
                            }
							break;
						}
					}
				}
				else{
					for ( var i = 0; i < registrations.length; i++) {
						ice.push.removeGroupMember(groupName,registrations[i][1]);
						$.push.pushIds[registrations[i][1]] = null;
						registrations[i] = null;
					}
                    console.log('removed listening notifications [group: '+groupName+', callbackID: '+id+']');
					this.groups[groupName] = null;
				}
			}
		}
	};
	$.fn.loadPushUpdates = function(groupName, getURL){
		var pushId = ice.push.createPushId();
    	if ($.push.groups[groupName] == null) {
    		$.push.groups[groupName] = new Array();
		}
    	$.push.groups[groupName].push( [ getURL, pushId ]);
    	$.push.pushIds[pushId] = [this,getURL];
    	ice.push.addGroupMember(groupName, pushId);
		ice.push.register( [ pushId ], function(pushId) {
			$.get($.push.pushIds[pushId][1],function (data){
				$($.push.pushIds[pushId][0]).each( function(idx,elem){
					$(elem).html(data);
				});
			});
		});
    	return this;
    };
    $.fn.appendPushUpdates = function(groupName, getURL){
    	var pushId = ice.push.createPushId();
    	if ($.push.groups[groupName] == null) {
    		$.push.groups[groupName] = new Array();
		}
    	$.push.groups[groupName].push( [ getURL, pushId ]);
    	$.push.pushIds[pushId] = [this,getURL];
    	ice.push.addGroupMember(groupName, pushId);
		ice.push.register( [ pushId ], function(pushId) {
			$.get($.push.pushIds[pushId][1],function (data){
				$($.push.pushIds[pushId][0]).each( function(idx,elem){
					$(elem).append(data);
				});
			});
		});
    	return this;
    };
	return this;
})(jQuery);

var _remove = $.fn.remove;
$.fn.remove = function() {
        $("*", this).add(this).triggerHandler("remove.icespush");
        return _remove.apply(this, arguments );
};