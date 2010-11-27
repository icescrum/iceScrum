/*
 * jQuery JavaScript DnD (Drag and Drop) plugin v0.1a
 *
 * Copyright 2010, Manuarii Stein
 * Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 *
 * Use the jQuery library under MIT licence
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 * Date: Sun Jul 18, 2010
 */

(function(jQuery) {
		// DND plugin
    jQuery.fn.dnd = function(options) {
				if ((typeof options) == "string") {
						var result
						jQuery.each(this, function(index, elem){
								result = jQuery.dnd[options](this, arguments);
						});
            return result;
        }

				var opts = jQuery.extend({}, $.fn.dnd.defaults, options);
				var events = $.fn.dnd.eventsName;

				// Apply the DND on all the targeted elements
				jQuery.each(this, function(index, elem){
					// If the elements was already "DND enhanced", we clean the data before
					var self = this;
					if(self.isDroppable) {
						jQuery.dnd['destroy'](self, true);
					}
					this.dnd = {opts:opts, wrappedEvents:{}};
					jQuery.each(events, function(optionName, eventName){
						// If the helper is defined
						if(opts.dropHelper != null && eventName == 'dragenter'){
							jQuery.dnd.dropHelperHandler(self, opts.dropHelper);
						}
						self.isDroppable = true;
						jQuery.dnd.attachEvent(self, eventName, opts[optionName]);
					});

				});
    };

		// Events names
		jQuery.fn.dnd.eventsName = {
			drag:'drag',
			dragStart:'dragstart',
			dragOver:'dragover',
			dragEnter:'dragenter',
			dragLeave:'dragleave',
			dragEnd:'dragend',
			drop:'drop'
		};

		// Default options
    jQuery.fn.dnd.defaults = {
			greedy:true,
			drag:function(event){},
			dragStart:function(event){},
			dragOver:function(event){},
			dragEnter:function(event){jQuery(this).addClass('dnd-hoverclass');},
			dragLeave:function(event){jQuery(this).removeClass('dnd-hoverclass');},
			dragEnd:function(event){},
			drop:function(event){},
			dropHelper:null
    };

		// Toolkit
    jQuery.dnd = {
				// Attach the drag & drop related events on the target
        attachEvent: function (target, eventName, handler) {
					var target = target;

					var wrapper = function(event){
						target.dnd.handler = handler;
						jQuery.dnd._wrapper.apply(target, [event]);
					};
					// Use attachEvent on IE, and addEventListener on the others
					// ToDo: check use standards on IE >= 9 if available
					if(jQuery.browser.msie){
						target.attachEvent('on'+eventName, wrapper);
					} else {
						target.addEventListener(eventName, wrapper, false);
					}
					if(!target.dnd.wrappedEvents) {
						target.dnd.wrappedEvents = {};
					}
					target.dnd.wrappedEvents[eventName] = wrapper;
				},

				// Detach the drag & drop related events from the target
				detachEvent: function(target, eventName, handler) {
					// ToDo: check use standards on IE >= 9 if available
					if(jQuery.browser.msie){
						target.detachEvent('on'+eventName, handler);
					} else {
						target.removeEventListener(eventName, handler, false);
					}
				},

				// The handlers are wrapped into a anonymous function that always
				// call the preventDefault() & stopPropagation() methods on the event.
				// This is to prevent conflict with the browser default action.
				// This wrapper also apply some fixes to the dataTransfer object.
				_wrapper: function(event){
					// Fix the event to make it usable seamlessly like any other jQuery events
					var originalEvent = event || window.event;
					event = jQuery.event.fix( event || window.event );
					var target = this;
					var handler = this.dnd.handler;

					// Additional fixes
					event.dataTransfer = jQuery.dnd._dataTransferFix(originalEvent.dataTransfer);

					if(event.type == "dragenter")
						if(target.helper) target.helper.dragEnter.apply($(target.helper.selector)[0], [event, target]);

					// Mozilla Firefox 3.6 fails at handling dragenter & dragleave properly (same as mouseover & mouseout)
					// so we have to add a trick to try to simulate proper dragenter & dragleave events
					if(jQuery.browser.mozilla && (event.type == "dragenter" || event.type == "dragleave")){
							jQuery.dnd._withinElement(target, event, handler);
					// For other browsers, we just execute the handler with the current target context
					} else {
						handler.apply(target, [event]);
					}

					// Prevent the browser native handler for those events
					event.preventDefault();

					// If the greedy option is true, then we stop the propagation of the event to the parent elements
					if(target.dnd.opts.greedy){
						event.stopPropagation();
					}
					// Call the dragLeave event if we drop something
					if(event.type=="drop")
						this.dnd.opts.dragLeave.apply(this, [event]);
				},

				// This function simulate proper dragenter & dragleave events in Firefox
				// This is a variant of the original jQuery withinElement function used for mouseenter & mouseleave
				_withinElement:function(target, event, handler) {
					// Check if dragenter is still within the same parent element
					var parent = event.relatedTarget;

					// Node type "object Text" are not considered as proper "sub-elements"
					if(!parent || parent.nodeType == 3) return;

					// Firefox sometimes assigns relatedTarget a XUL element
					// which we cannot access the parentNode property of
					try {
						// Traverse up the tree
						while ( parent && parent !== target ) {
							parent = parent.parentNode;
						}
						// handle event if we actually just dragged on to a non sub-element
						if ( parent !== target )
							handler.apply( target, [event] );
					// assuming we've left the element since we most likely dragged on a xul element
					} catch(e) { }
				},

				// Create a wrapper for the dataTransfer object to get a consistent interface in every browsers
				_dataTransferFix:function(dtObject){
					// By default, we are just delegating the work to the original dataTransfer object
					var dt = {
						originalDataTransfer:dtObject,
						types:dtObject.types,
						clearData:dtObject.clearData,
						setData:dtObject.setData
					}
					// Some properties are not supported by every browsers and cannot be simulated.
					// Those are checked case by case, and they are replaced by stubs to prevent javascript failures
					if(dtObject.files)
						dt.files = dtObject.files;
					else
						dt.files = []; // Cannot do much more in browsers not supporting the file API

					if(dtObject.addElement)
						dt.addElement = dtObject.addElement;
					else
						dt.addElement = function(element){};

					if(dtObject.setDragImage)
						dt.setDragImage = dtObject.setDragImage;
					else
						dt.setDragImage = function(image, x, y){};

					// Map equivalents getData types
					dt.getData = function(type) {
						var data
						// W3C state that "text" should be considered equivalent to "text/plain"
						// and "url" to "text/uri-list". Since old browsers and even some more modern
						// only knows the "text" and "url", we map the "text/plain" & "text/uri-list"
						// to use their equivalents in case of failure
						switch(type){
							case 'text/plain':
								// A non-valid argument provoke an exception in ie, we just ignore it
								try { data = dtObject.getData('text/plain'); }catch(e){}
								if(!data || data == '')
									data = dtObject.getData('text');
								break;

							case 'text/uri-list':
								try { data = dtObject.getData('text/uri-list'); }catch(e){}
								if(!data || data == '')
									data = dtObject.getData('url');
								break;
							// If the data cannot be retrieve, a empty string is returned
							default:
								try { data = dtObject.getData(type); }catch(e){}
								if(!data)
									data = '';
						}
						return data;
					};

					// Shortcuts for getData('text/plain') & getData('text/uri-list')
					dt.text = function(){return dt.getData('text/plain');};
					dt.url = function(){return dt.getData('text/uri-list');};

					return dt;
				},

				// Apply the event listening to the helper
				dropHelperHandler:function(target, dropHelper) {
					var helper;
					if(typeof dropHelper === "string")
						helper = $(dropHelper);
					else
						helper = dropHelper;
					var target = target;
					helper.hide();
					helper[0].target = target;

					var dragLeave = function(event){
						$(this).hide();
						var target = $(this.target);
						target.css('position', target.data('origPos') ? target.data('origPos') : "");
					};

					var dragEnter = function(event, target){
						if($(target).css('position') != 'absolute' && $(target).css('position') != 'relative') {
							$(target).data('origPos', $(target).css('position'));
							$(target).css('position', 'relative');
						}
						$(this).addClass('dnd-drophelper');
						$(this).css({
							width:$(target).innerWidth(),
							height:$(target).innerHeight()
						});
						if($(this).parent() != $(target)) {
							$(this).appendTo($(target));
						}
						$(this).show();
					};

					// The helper let the event propagate to its parent so we can still drop something and trigger
					// the expected handler
					helper[0].dnd = {
						opts:{
							greedy:false,
							dragLeave:dragLeave
						}
					};

					// The helper shows itself when the user drag something over the parent element
					target.helper = {
						selector:helper.selector,
						dragEnter:dragEnter
					};

					// When the user leaves the helper, hide the helper
					jQuery.dnd.attachEvent(helper[0], 'dragleave', dragLeave);
					// Drop listener to trigger dragLeave on drop
					jQuery.dnd.attachEvent(helper[0], 'drop', function(event){});
					// Call dragLeave onclick
					helper.click(function(event){
						this.dnd.opts.dragLeave.apply(this, [event]);
					});
				},

				// Return true if the target is droppable
				droppable:function(target) {
					return (target.isDroppable != undefined && target.isDroppable == true) || false;
				},

				// Destroy the events listeners associated with the drag & drop plugin on the specified target
				destroy:function(target, keepHelper){
					var events = jQuery.fn.dnd.eventsName;
					var opts = target.dnd.opts;
					// If the helper was defined
					if(opts.dropHelper != null && !keepHelper){
						jQuery(opts.dropHelper).remove();
					}
					target.isDroppable = false;
					jQuery(target).removeClass('dnd-hoverclass');
					jQuery.each(events, function(optionName, eventName){
						jQuery.dnd.detachEvent(target, eventName, target.dnd.wrappedEvents[eventName]);
					});
				}
    };
}(jQuery));
