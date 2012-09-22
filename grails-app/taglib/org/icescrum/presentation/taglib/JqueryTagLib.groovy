package org.icescrum.presentation.taglib

/**
 * Created with IntelliJ IDEA.
 * User: vbarrier
 * Date: 21/09/12
 * Time: 09:42
 * To change this template use File | Settings | File Templates.
 */
class JqueryTagLib {
    static namespace = 'jq'
   /* Adds the jQuery().ready function to the code
   *
   * @param attrs No use
   * @param body  The javascript code to execute
   */
   def jquery = {attrs, body ->
        out << '<script type="text/javascript">jQuery(function(){'
        out << body()
        out << '}); </script>'
   }
}
