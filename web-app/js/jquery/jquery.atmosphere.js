/*
 * jQuery Stream 1.0
 * Comet Streaming JavaScript Library 
 * http://code.google.com/p/jquery-stream/
 * 
 * Copyright 2011, Donghwan Kim 
 * Licensed under the Apache License, Version 2.0
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Compatible with jQuery 1.4+
 */
(function($, undefined) {

    // Does the throbber of doom exist?
    var throbber = $.browser.webkit && !$.isReady;
    if (throbber) {
        $(window).load(function() {
            throbber = false;
        });
    }

    // Stream is based on The WebSocket API
    // http://dev.w3.org/html5/websockets/
    function Stream(url, options) {
        // Assigns url and merges options
        this.url = url;
        this.options = $.extend(true, {}, this.options, options);

        for (var i in {open: 1, message: 1, error: 1, close: 1}) {
            this.options[i] = $.makeArray(this.options[i]);
        }

        // The url is a identifier of this instance within the document
        Stream.instances[this.url] = this;

        var self = this;
        if (!throbber) {
            setTimeout(function() {
                self.open();
            }, 0);
        } else {
            switch (this.options.throbber.type || this.options.throbber) {
                case "lazy":
                    $(window).load(function() {
                        setTimeout(function() {
                            self.open();
                        }, self.options.throbber.delay || 50);
                    });
                    break;
                case "reconnect":
                    self.open();
                    $(window).load(function() {
                        if (self.readyState === 0) {
                            self.options.open.push(function() {
                                self.options.open.pop();
                                setTimeout(function() {
                                    reconnect();
                                }, 10);
                            });
                        } else {
                            reconnect();
                        }

                        function reconnect() {
                            self.options.close.push(function() {
                                self.options.close.pop();
                                setTimeout(function() {
                                    self.readyState = 0;
                                    self.open();
                                }, self.options.throbber.delay || 50);
                            });

                            var reconn = self.options.reconnect;
                            self.close();
                            self.options.reconnect = reconn;
                        }
                    });
                    break;
            }
        }
    }

    $.extend(Stream.prototype, {

                // Default options
                options: {
                    // Whether to automatically reconnect when connection closed
                    reconnect: true,
                    // Only for WebKit
                    throbber: "lazy",
                    // Message data type
                    dataType: "text",
                    // Message data converters
                    converters: {
                        text: window.String,
                        // jQuery.parseJSON is in jQuery 1.4.1
                        json: $.parseJSON,
                        // jQuery.parseXML is in jQuery 1.5
                        xml: $.parseXML
                    }
                },

                // Current stream connection's identifier within the server
                id: null,

                // The state of the connection
                // 0: CONNECTING, 1: OPEN, 2: CLOSING, 3: CLOSED
                readyState: 0,

                send: function(data) {
                    if (this.readyState === 0) {
                        $.error("INVALID_STATE_ERR: Stream not open");
                    }

                    if (arguments.length) {
                        // Converts data if not already a string and pushes it into the data queue
                        this.dataQueue.push(!data ?
                                "" :
                                ((typeof data === "string" ? data : $.param(data, $.ajaxSettings.traditional)) + "&"));
                    }

                    if (this.sending !== true) {
                        this.sending = true;

                        // Performs an Ajax iterating through the data queue
                        (function post() {
                            if (this.readyState === 1 && this.dataQueue.length) {
                                $.ajax({
                                            url: this.url,
                                            context: this,
                                            type: "POST",
                                            data: this.dataQueue.shift() + this.paramMetadata("send"),
                                            complete: post
                                        });
                            } else {
                                this.sending = false;
                            }
                        }).call(this);
                    }
                },

                close: function() {
                    // Do nothing if the readyState is in the CLOSING or CLOSED
                    if (this.readyState < 2) {
                        this.readyState = 2;

                        // Notifies the server
                        $.post(this.url, this.paramMetadata("close"));

                        // Prevents reconnecting
                        this.options.reconnect = false;
                        this.abort();
                    }
                },

                paramMetadata: function(type, props) {
                    // Always includes connection id and communication type
                    props = $.extend({}, props, {id: this.id, type: type});

                    var answer = {};
                    for (var key in props) {
                        answer["metadata." + key] = props[key];
                    }

                    return $.param(answer);
                },

                handleResponse: function(text) {
                    if (this.readyState === 0) {
                        // The top of the response is made up of the id and padding
                        this.id = text.substring(0, text.indexOf(";"));
                        this.message = {index: text.indexOf(";", this.id.length + 1) + 1, size: null, data: ""};
                        this.dataQueue = this.dataQueue || [];

                        this.readyState = 1;
                        this.trigger("open");
                    }

                    // Parses messages
                    // message format = message-size ; message-data ;
                    for (; ;) {
                        if (this.message.size == null) {

                            if (text.indexOf('<!-- EOD -->') != -1 && this.message.index <= 2113) {
                                this.message.index = 2113;
                            }
                            // Checks a semicolon of size part
                            var sizeEnd = text.indexOf(";", this.message.index);
                            if (sizeEnd < 0) {
                                return;
                            }

                            this.message.size = +text.substring(this.message.index, sizeEnd);
                            this.message.index = sizeEnd + 1;
                        }

                        var data = text.substr(this.message.index, this.message.size - this.message.data.length);
                        this.message.data += data;
                        this.message.index += data.length;

                        // Has this message been completed?
                        if (this.message.size !== this.message.data.length) {
                            return;
                        }

                        // Checks a semicolon of data part
                        var dataEnd = text.indexOf(";", this.message.index);
                        if (dataEnd < 0) {
                            return;
                        }
                        this.message.index = dataEnd + 1;

                        // Converts the data type
                        this.message.data = this.options.converters[this.options.dataType](this.message.data);

                        if (this.readyState < 3) {
                            // Pseudo MessageEvent
                            this.trigger("message", {
                                        data: this.message.data,
                                        origin: "",
                                        lastEventId: "",
                                        source: null,
                                        ports: null,
                                        openMessageEvent: $.noop
                                    });
                        }

                        // Resets the data and size
                        this.message.size = null;
                        this.message.data = "";
                    }
                },

                handleClose: function(isError) {
                    var readyState = this.readyState;
                    this.readyState = 3;

                    if (isError === true) {
                        // Prevents reconnecting
                        this.options.reconnect = false;

                        switch (readyState) {
                            // If establishing a connection fails, fires the close event instead of the error event
                            case 0:
                                // Pseudo CloseEvent
                                this.trigger("close", {
                                            wasClean: false,
                                            code: "",
                                            reason: "",
                                            initCloseEvent: $.noop
                                        });
                                break;
                            case 1:
                            case 2:
                                this.trigger("error");
                                break;
                        }
                    } else {
                        // Pseudo CloseEvent
                        this.trigger("close", {
                                    // Presumes that the stream closed cleanly
                                    wasClean: true,
                                    code: "",
                                    reason: "",
                                    initCloseEvent: $.noop
                                });

                        // Reconnect?
                        if (this.options.reconnect === true) {
                            this.readyState = 0;
                            this.open();
                        }
                    }
                },

                trigger: function(type, props) {
                    var event = $.extend($.Event(type), {
                                eventPhase: 2,
                                currentTarget: this,
                                srcElement: this,
                                target: this,
                                bubbles: false,
                                cancelable: false
                            }, props),
                            applyArgs = [event];

                    // Triggers local event handlers
                    if (this.options[type].length) {
                        for (var fn, i = 0; fn = this.options[type][i]; i++) {
                            fn.apply(this.options.context, applyArgs);
                        }
                    }

                    // Triggers global event handlers
                    $.event.trigger("stream" + type.substring(0, 1).toUpperCase() + type.substring(1), applyArgs);
                },

                openURL: function() {
                    var rts = /([?&]_=)[^&]*/;

                    // Attaches a time stamp
                    return (rts.test(this.url) ? this.url : (this.url + (/\?/.test(this.url) ? "&" : "?") + "_="))
                            .replace(rts, "$1" + new Date().getTime());
                }

            });

    $.extend(Stream, {

                instances: {},

                // Prototype according to transport
                transports: {

                    // XMLHttpRequest: Modern browsers except IE
                    xhr: {
                        open: function() {
                            var self = this;

                            this.xhr = new window.XMLHttpRequest();
                            this.xhr.onreadystatechange = function() {
                                switch (this.readyState) {
                                    case 2:
                                        try {
                                            $.noop(this.status);
                                        } catch (e) {
                                            // Opera throws an exception when accessing status property in LOADED state
                                            this.opera = true;
                                        }
                                        break;
                                    // Handles open and message event
                                    case 3:
                                        if (this.status !== 200) {
                                            return;
                                        }

                                        self.handleResponse(this.responseText);

                                        // For Opera
                                        if (this.opera && !this.polling) {
                                            this.polling = true;

                                            iterate(this, function() {
                                                if (this.readyState === 4) {
                                                    return false;
                                                }

                                                if (this.responseText.length > self.message.index) {
                                                    self.handleResponse(this.responseText);
                                                }
                                            });
                                        }
                                        break;
                                    // Handles error or close event
                                    case 4:
                                        self.handleClose(this.status !== 200);
                                        break;
                                }
                            };
                            this.xhr.open("GET", this.openURL());
                            this.xhr.send();
                        },
                        abort: function() {
                            this.xhr.abort();
                        }
                    },

                    // XDomainRequest: IE9, IE8
                    xdr: {
                        open: function() {
                            var self = this;

                            this.xdr = new window.XDomainRequest();
                            // Handles open and message event
                            this.xdr.onprogress = function() {
                                self.handleResponse(this.responseText);
                            };
                            // Handles error event
                            this.xdr.onerror = function() {
                                self.handleClose(true);
                            };
                            // Handles close event
                            this.xdr.onload = function() {
                                self.handleClose();
                            };
                            this.xdr.open("GET", this.openURL());
                            this.xdr.send();
                        },
                        abort: function() {
                            var onload = this.xdr.onload;
                            this.xdr.abort();
                            onload();
                        }
                    },

                    // Hidden iframe: IE7, IE6
                    iframe: {
                        open: function() {
                            this.doc = new window.ActiveXObject("htmlfile");
                            this.doc.open();
                            this.doc.close();

                            var iframe = this.doc.createElement("iframe");
                            iframe.src = this.openURL();

                            this.doc.body.appendChild(iframe);

                            // For the server to respond in a consistent format regardless of user agent, we polls response text
                            var cdoc = iframe.contentDocument || iframe.contentWindow.document;

                            iterate(this, function() {
                                var html = cdoc.documentElement;
                                if (!html) {
                                    return;
                                }

                                // Detects connection failure
                                if (cdoc.readyState === "complete") {
                                    try {
                                        $.noop(cdoc.fileSize);
                                    } catch(e) {
                                        this.handleClose(true);
                                        return false;
                                    }
                                }

                                var response = cdoc.body.firstChild;

                                // Handles open event
                                this.handleResponse(response.innerText);

                                // Handles message and close event
                                iterate(this, function() {
                                    var text = response.innerText;
                                    if (text.length > this.message.index) {
                                        this.handleResponse(text);

                                        // Empties response every time that it is handled
                                        response.innerText = "";
                                        this.message.index = 0;
                                    }

                                    if (cdoc.readyState === "complete") {
                                        this.handleClose();
                                        return false;
                                    }
                                });

                                return false;
                            });
                        },
                        abort: function() {
                            this.doc.execCommand("Stop");
                            this.doc = null;
                        }
                    }

                }

            });

    // Detects Comet Streaming transport
    var transport = window.XDomainRequest ? "xdr" : window.ActiveXObject ? "iframe" : window.XMLHttpRequest ? "xhr" : null;
    if (!transport) {
        $.error("Unsupported browser");
    }

    // Completes the prototype
    $.extend(true, Stream.prototype, Stream.transports[transport]);

    // In case of reconnection, continues to communicate
    $(document).bind("streamOpen", function(e, event) {
        event.target.send();
    });

    // Closes all stream when the document is unloaded
    // this works right only in IE
    $(window).unload(function() {
        $.each(Stream.instances, function() {
            this.close();
        });
    });

    function iterate(context, fn) {
        (function loop() {
            setTimeout(function() {
                if (fn.call(context) === false) {
                    return;
                }

                loop();
            }, 0);
        })();
    }

    $.stream = function(url, options) {
        if (!arguments.length) {
            for (var i in Stream.instances) {
                return Stream.instances[i];
            }
            return null;
        }

        return Stream.instances[url] || new Stream(url, options);
    };

    $.stream.version = "1.0";

    $.each("streamOpen streamMessage streamError streamClose".split(" "), function(i, o) {
        $.fn[o] = function(f) {
            return this.bind(o, f);
        };
    });

})(jQuery);