/*
 * Copyright (c) 2011 Kagilum.
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
 *
 */

(function($,window,undefined){
  '$:nomunge'; // Used by YUI compressor.

  var str_hashchange = 'hashchange',
    doc = document,
    fake_onhashchange,
    special = $.event.special,
    doc_mode = doc.documentMode,
    supports_onhashchange = 'on' + str_hashchange in window && ( doc_mode === undefined || doc_mode > 7 );

  function get_fragment( url ) {
    url = url || location.href;
    return '#' + url.replace( /^[^#]*#?(.*)$/, '$1' );
  };

  $.fn[ str_hashchange ] = function( fn ) {
    return fn ? this.bind( str_hashchange, fn ) : this.trigger( str_hashchange );
  };

  $.fn[ str_hashchange ].delay = 50;
  special[ str_hashchange ] = $.extend( special[ str_hashchange ], {

    setup: function() {
      if ( supports_onhashchange ) { return false; }
      $( fake_onhashchange.start );
    },

    teardown: function() {
      if ( supports_onhashchange ) { return false; }
      $( fake_onhashchange.stop );
    }

  });

  fake_onhashchange = (function(){
    var self = {},
      timeout_id,

      last_hash = get_fragment(),

      fn_retval = function(val){ return val; },
      history_set = fn_retval,
      history_get = fn_retval;

    self.start = function() {
      timeout_id || poll();
    };

    self.stop = function() {
      timeout_id && clearTimeout( timeout_id );
      timeout_id = undefined;
    };

    function poll() {
      var hash = get_fragment(),
        history_hash = history_get( last_hash );

      if ( hash !== last_hash ) {
        history_set( last_hash = hash, history_hash );

        $(window).trigger( str_hashchange );

      } else if ( history_hash !== last_hash ) {
        location.href = location.href.replace( /#.*/, '' ) + history_hash;
      }

      timeout_id = setTimeout( poll, $.fn[ str_hashchange ].delay );
    };

    return self;
  })();

})(jQuery,this);