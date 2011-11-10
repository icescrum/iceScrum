/*
 * jQuery Stream 1.2
 * Comet Streaming JavaScript Library 
 * http://code.google.com/p/jquery-stream/
 * 
 * Copyright 2011, Donghwan Kim 
 * Licensed under the Apache License, Version 2.0
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Compatible with jQuery 1.5+
 */
(function($, undefined) {

	var // Stream object instances
		instances = {},

		// Streaming agents
		agents = {},

		// HTTP Streaming transports
		transports = {},

		// Does the throbber of doom exist?
		throbber = $.browser.webkit && !$.isReady;

	// Once the window is fully loaded, the throbber of doom will not be appearing
	if (throbber) {
		$(window).load(function() {
			throbber = false;
		});
	}

	// Stream is based on The WebSocket API
	// W3C Working Draft 19 April 2011 - http://www.w3.org/TR/2011/WD-websockets-20110419/
	$.stream = function(url, options) {

		// Returns the first Stream in the document
		if (!arguments.length) {
			for (var i in instances) {
				return instances[i];
			}

			return null;
		}

		// Stream to which the specified url or alias is mapped
		var instance = instances[url];

		if (!options) {
			return instance || null;
		} else if (instance && instance.readyState < 3) {
			return instance;
		}

		var // Stream object
			stream = {

				// URL to which to connect
				url: url,

				// Merges options
				options: $.stream.setup({}, options),

				// The state of stream
				// 0: CONNECTING, 1: OPEN, 2: CLOSING, 3: CLOSED
				readyState: 0,

				// Fake send
				send: function() {},

				// Fake close
				close: function() {}

			},
			match = /^(http|ws)s?:/.exec(stream.url),
			open = function() {
				// Delegates open process
				agents[stream.options.type](stream);
			};

		// Stream type
		if (match) {
			stream.options.type = match[1];
		}

		// Makes arrays of event handlers
		for (var i in {open: 1, message: 1, error: 1, close: 1}) {
			stream.options[i] = $.makeArray(stream.options[i]);
		}

		// The url and alias are a identifier of this instance within the document
		instances[stream.url] = stream;
		if (stream.options.alias) {
			instances[stream.options.alias] = stream;
		}

		// Deals with the throbber of doom
		if (stream.options.type === "ws" || !throbber) {
			open();
		} else {
			switch (stream.options.throbber.type || stream.options.throbber) {
			case "lazy":
				$(window).load(function() {
					setTimeout(open, stream.options.throbber.delay || 50);
				});
				break;
			case "reconnect":
				open();
				$(window).load(function() {
					if (stream.readyState === 0) {
						stream.options.open.push(function() {
							stream.options.open.pop();
							setTimeout(reconnect, 10);
						});
					} else {
						reconnect();
					}

					function reconnect() {
						stream.options.close.push(function() {
							stream.options.close.pop();
							setTimeout(function() {
								$.stream(stream.url, stream.options);
							}, stream.options.throbber.delay || 50);
						});

						var reconn = stream.options.reconnect;
						stream.close();
						stream.options.reconnect = reconn;
					}
				});
				break;
			}
		}

		return stream;
	};

	$.extend($.stream, {

		version: "1.2",

		// Logic borrowed from jQuery.ajaxSetup
		setup: function(target, options) {
			if (!options) {
				options = target;
				target = $.extend(true, $.stream.options, options);
			} else {
				$.extend(true, target, $.stream.options, options);
			}

			for (var field in {context: 1, url: 1}) {
				if (field in options) {
					target[field] = options[field];
				} else if (field in $.stream.options) {
					target[field] = $.stream.options[field];
				}
			}

			return target;
		},

		options: {
			// Stream type
			type: (window.MozWebSocket || window.WebSocket) ? "ws" : "http",
			// Whether to automatically reconnect when stream closed
			reconnect: true,
			// Whether to trigger global stream event handlers
			global: true,
			// Only for WebKit
			throbber: "lazy",
			// Message data type
			dataType: "text",
			// Message data converters
			converters: {
				text: window.String,
				json: $.parseJSON,
				xml: $.parseXML
			}
			// Additional parameters for GET request
			// openData: null,
			// WebSocket constructor argument
			// protocols: null,
			// XDomainRequest transport
			// enableXDR: false,
			// rewriteURL: null
			// Polling interval
			// operaInterval: 0
			// iframeInterval: 0
		}

	});

	$.extend(agents, {

		// WebSocket wrapper
		ws: function(stream) {

            if (!(window.MozWebSocket || window.WebSocket)) {
				return;
			}

            var // Absolute WebSocket URL
				url = prepareURL(getAbsoluteURL(stream.url).replace(/^http/, "ws"), stream.options.openData);

	        // WebSocket instance
            var ws;
            if (window.WebSocket){
                ws = stream.options.protocols ? new window.WebSocket(url, stream.options.protocols) : new window.WebSocket(url);
            }else{
                ws = stream.options.protocols ? new window.MozWebSocket(url, stream.options.protocols) : new window.MozWebSocket(url);
            }

			// WebSocket event handlers
			$.extend(ws, {
				onopen: function(event) {
					stream.readyState = 1;
					trigger(stream, event);
				},
				onmessage: function(event) {
                    trigger(stream, $.extend({}, event, {data: stream.options.converters[stream.options.dataType](event.data)}));
				},
				onerror: function(event) {
					stream.options.reconnect = false;
					trigger(stream, event);
				},
				onclose: function(event) {
					var readyState = stream.readyState;

					stream.readyState = 3;
					trigger(stream, event);

					// Reconnect?
					if (stream.options.reconnect && readyState !== 0) {
						$.stream(stream.url, stream.options);
					}
				}
			});

			// Overrides send and close
			$.extend(stream, {
				send: function(data) {
					if (stream.readyState === 0) {
						$.error("INVALID_STATE_ERR: Stream not open");
					}

					ws.send(typeof data === "string" ? data : param(data));
				},
				close: function() {
					if (stream.readyState < 2) {
						stream.readyState = 2;
						stream.options.reconnect = false;
						ws.close();
					}
				}
			});
		},

		// HTTP Streaming
		http: function(stream) {
			var // Transport
				transportFn,
				transport,
				// Low-level request and response handler
				handleOpen,
				handleMessage,
				handleSend,
				// Latch for AJAX
				sending,
				// Data queue
				dataQueue = [],
				// Helper object for parsing response
				message = {
					// The index from which to start parsing
					index: 0,
					// The temporary data
					data: ""
				};

			// Chooses a proper transport
			transportFn = transports[
				// xdr
				stream.options.enableXDR && window.XDomainRequest ? "xdr" :
				// iframe
				window.ActiveXObject ? "iframe" :
				// xhr
				window.XMLHttpRequest ? "xhr" : null];

			if (!transportFn) {
				return;
			}

			// Default response handler
			handleOpen = stream.options.handleOpen || function(text, message, stream) {
				// The top of the response is made up of the id and padding
				// optional identifier within the server
				stream.id = text.substring(0, text.indexOf(";"));
				// message.index = text.indexOf(";", stream.id.length + ";".length) + ";".length;
				message.index = text.indexOf(";", stream.id.length + 1) + 1;
			};
			handleMessage = stream.options.handleMessage || function(text, message) {
				// Response could contain a single message, multiple messages or a fragment of a message
				// default message format is message-size ; message-data ;
				if (message.size == null) {
					// Checks a semicolon of size part
					var sizeEnd = text.indexOf(";", message.index);
					if (sizeEnd < 0) {
						return false;
					}

					message.size = +text.substring(message.index, sizeEnd);
					// index: sizeEnd + ";".length,
					message.index = sizeEnd + 1;
				}

				var data = text.substr(message.index, message.size - message.data.length);
				message.data += data;
				message.index += data.length;

				// Has stream message been completed?
				if (message.size !== message.data.length) {
					return false;
				}

				// Checks a semicolon of data part
				var dataEnd = text.indexOf(";", message.index);
				if (dataEnd < 0) {
					return false;
				}

				// message.index = dataEnd + ";".length;
				message.index = dataEnd + 1;

				// Completes parsing
				delete message.size;
			};

			// Default request handler
			handleSend = stream.options.handleSend || function(type, options, stream) {
				var metadata = {"metadata.id": stream.id, "metadata.type": type};

				options.data =
					// Close
					type === "close" ? param(metadata) :
					// Send
					// converts data if not already a string
					((typeof options.data === "string" ? options.data : param(options.data)) + "&" + param(metadata));
			};

			transport = transportFn(stream, {
				response: function(text) {
					if (stream.readyState === 0) {
						if (handleOpen(text, message, stream) === false) {
							return;
						}

						stream.readyState = 1;
						trigger(stream, "open");
					}

					for (;;) {
						if (handleMessage(text, message, stream) === false) {
							return;
						}

						if (stream.readyState < 3) {
							// Pseudo MessageEvent
							trigger(stream, "message", {
								// Converts the data type
								data: stream.options.converters[stream.options.dataType](message.data),
								origin: "",
								lastEventId: "",
								source: null,
								ports: null
							});
						}

						// Resets the data
						message.data = "";
					}
				},
				close: function(isError) {
					var readyState = stream.readyState;
					stream.readyState = 3;

					if (isError) {
						// Prevents reconnecting
						stream.options.reconnect = false;

						// If establishing a connection fails, fires the close event instead of the error event
						if (readyState === 0) {
							// Pseudo CloseEvent
							trigger(stream, "close", {
								wasClean: false,
								code: null,
								reason: ""
							});
						} else {
							trigger(stream, "error");
						}
					} else {
						// Pseudo CloseEvent
						trigger(stream, "close", {
							// Presumes that the stream closed cleanly
							wasClean: true,
							code: null,
							reason: ""
						});

						// Reconnect?
						if (stream.options.reconnect) {
							$.stream(stream.url, stream.options);
						}
					}
				}
			}, message);

			transport.open();

			// Overrides send and close
			$.extend(stream, {
				send: function(data) {
					if (stream.readyState === 0) {
						$.error("INVALID_STATE_ERR: Stream not open");
					}

					// Pushes the data into the queue
					dataQueue.push(data);

					if (!sending) {
						sending = true;

						// Performs an Ajax iterating through the data queue
						(function post() {
							if (stream.readyState === 1 && dataQueue.length) {
								var options = {url: stream.url, type: "POST", data: dataQueue.shift()};

								if (handleSend("send", options, stream) !== false) {
									$.ajax(options).complete(post);
								} else {
									post();
								}
							} else {
								sending = false;
							}
						})();
					}
				},
				close: function() {
					// Do nothing if the readyState is in the CLOSING or CLOSED
					if (stream.readyState < 2) {
						stream.readyState = 2;

						var options = {url: stream.url, type: "POST"};

						if (handleSend("close", options, stream) !== false) {
							// Notifies the server
							$.ajax(options);
						}

						// Prevents reconnecting
						stream.options.reconnect = false;
						transport.close();
					}
				}
			});
		}

	});

	$.extend(transports, {

		// XMLHttpRequest: Modern browsers except Internet Explorer
		xhr: function(stream, handler, message) {
			var stop,
				polling,
				preStatus,
				xhr = new window.XMLHttpRequest();

			xhr.onreadystatechange = function() {
				switch (xhr.readyState) {
				// Handles open and message event
				case 3:
					if (xhr.status !== 200) {
						return;
					}

					handler.response(xhr.responseText);

					// For Opera
					if ($.browser.opera && !polling) {
						polling = true;

						stop = iterate(function() {
							if (xhr.readyState === 4) {
								return false;
							}

							if (xhr.responseText.length > message.index) {
								handler.response(xhr.responseText);
							}
						}, stream.options.operaInterval);
					}
					break;
				// Handles error or close event
				case 4:
					// HTTP status 0 could mean that the request is terminated by abort method
					// but it's not error in Stream object
					handler.close(xhr.status !== 200 && preStatus !== 200);
					break;
				}
			};

			return {
				open: function() {
					xhr.open("GET", prepareURL(stream.url, stream.options.openData));
					xhr.send();
				},
				close: function() {
					if (stop) {
						stop();
					}

					// Saves status
					try {
						preStatus = xhr.status;
					} catch (e) {}
					xhr.abort();
				}
			};
		},

		// Hidden iframe: Internet Explorer
		iframe: function(stream, handler, message) {
			var stop,
				closed,
				onload = function() {
					if (!closed) {
						closed = true;
						handler.close();
					}
				},
				doc = new window.ActiveXObject("htmlfile");

			doc.open();
			doc.close();

			return {
				open: function() {
					var iframe = doc.createElement("iframe");
					iframe.src = prepareURL(stream.url, stream.options.openData);

					doc.body.appendChild(iframe);

					// For the server to respond in a consistent format regardless of user agent, we polls response text
					var cdoc = iframe.contentDocument || iframe.contentWindow.document;

					stop = iterate(function() {
						if (!cdoc.documentElement) {
							return;
						}

						// Detects connection failure
						if (cdoc.readyState === "complete") {
							try {
								$.noop(cdoc.fileSize);
							} catch(e) {
								handler.close(true);
								return false;
							}
						}

						var response = cdoc.body.lastChild,
							readResponse = function() {
								// Clones the element not to disturb the original one
								var clone = response.cloneNode(true);

								// If the last character is a carriage return or a line feed, IE ignores it in the innerText property
								// therefore, we add another non-newline character to preserve it
								clone.appendChild(cdoc.createTextNode("."));

								var text = clone.innerText;
								return text.substring(0, text.length - 1);
							};

						// To support text/html content type
						if (!$.nodeName(response, "pre")) {
							// Injects a plaintext element which renders text without interpreting the HTML and cannot be stopped
							// it is deprecated in HTML5, but still works
							var head = cdoc.head || cdoc.getElementsByTagName("head")[0] || cdoc.documentElement,
								script = cdoc.createElement("script");

							script.text = "document.write('<plaintext>')";

							head.insertBefore(script, head.firstChild);
							head.removeChild(script);

							// The plaintext element will be the response container
							response = cdoc.body.lastChild;
						}

						// Handles open event
						handler.response(readResponse());

						// Handles message and close event
						stop = iterate(function() {
							var text = readResponse();
							if (text.length > message.index) {
								handler.response(text);

								// Empties response every time that it is handled
								response.innerText = "";
								message.index = 0;
							}

							if (cdoc.readyState === "complete") {
								onload();
								return false;
							}
						}, stream.options.iframeInterval);

						return false;
					});
				},
				close: function() {
					if (stop) {
						stop();
					}

					doc.execCommand("Stop");
					onload();
				}
			};
		},

		// XDomainRequest: Optionally Internet Explorer 8+
		xdr: function(stream, handler) {
			var xdr = new window.XDomainRequest(),
				rewriteURL = stream.options.rewriteURL || function(url) {
					// Maintaining session by rewriting URL
					// http://stackoverflow.com/questions/6453779/maintaining-session-by-rewriting-url
					var rewriters = {
						JSESSIONID: function(sid) {
							return url.replace(/;jsessionid=[^\?]*|(\?)|$/, ";jsessionid=" + sid + "$1");
						},
						PHPSESSID: function(sid) {
							return url.replace(/\?PHPSESSID=[^&]*&?|\?|$/, "?PHPSESSID=" + sid + "&").replace(/&$/, "");
						}
					};

					for (var name in rewriters) {
						// Finds session id from cookie
						var matcher = new RegExp("(?:^|;\\s*)" + encodeURIComponent(name) + "=([^;]*)").exec(document.cookie);
						if (matcher) {
							return rewriters[name](matcher[1]);
						}
					}

					return url;
				};

			// Handles open and message event
			xdr.onprogress = function() {
				handler.response(xdr.responseText);
			};
			// Handles error event
			xdr.onerror = function() {
				handler.close(true);
			};
			// Handles close event
			var onload = xdr.onload = function() {
				handler.close();
			};

			return {
				open: function() {
					xdr.open("GET", prepareURL(rewriteURL(stream.url), stream.options.openData));
					xdr.send();
				},
				close: function() {
					xdr.abort();
					onload();
				}
			};
		}

	});

	// Closes all stream when the document is unloaded
	// this works right only in IE
	$(window).bind("unload.stream", function() {
		for (var url in instances) {
			instances[url].close();
			delete instances[url];
		}
	});

	$.each("streamOpen streamMessage streamError streamClose".split(" "), function(i, o) {
		$.fn[o] = function(f) {
			return this.bind(o, f);
		};
	});

	// Works even in IE6
	function getAbsoluteURL(url) {
		var div = document.createElement("div");
		div.innerHTML = "<a href='" + url + "'/>";

		return div.firstChild.href;
	}

	function trigger(stream, event, props) {
		event = event.type ?
			event :
			$.extend($.Event(event), {bubbles: false, cancelable: false}, props);

		var handlers = stream.options[event.type],
			applyArgs = [event, stream];

		// Triggers local event handlers
		for (var i = 0, length = handlers.length; i < length; i++) {
			handlers[i].apply(stream.options.context, applyArgs);
		}

		if (stream.options.global) {
			// Triggers global event handlers
			$.event.trigger("stream" + event.type.substring(0, 1).toUpperCase() + event.type.substring(1), applyArgs);
		}
	}

	function prepareURL(url, data) {
		// Converts data into a query string
		if (data && typeof data !== "string") {
			data = param(data);
		}

		// Attaches a time stamp to prevent caching
		var ts = $.now(),
			ret = url.replace(/([?&])_=[^&]*/, "$1_=" + ts);

		return ret + (ret === url ? (/\?/.test(url) ? "&" : "?") + "_=" + ts : "") + (data ? ("&" + data) : "");
	}

	function param(data) {
		return $.param(data, $.ajaxSettings.traditional);
	}

	function iterate(fn, interval) {
		var timeoutId;

		// Though the interval is 0 for real-time application, there is a delay between setTimeout calls
		// For detail, see https://developer.mozilla.org/en/window.setTimeout#Minimum_delay_and_timeout_nesting
		interval = interval || 0;

		(function loop() {
			timeoutId = setTimeout(function() {
				if (fn() === false) {
					return;
				}

				loop();
			}, interval);
		})();

		return function() {
			clearTimeout(timeoutId);
		};
	}

})(jQuery);