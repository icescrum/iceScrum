/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Damien Vitrac (damien@oocube.com)
 * Manuarii Stein (manuarii.stein@icescrum.com)
 * Stephane Maldini (vincent.barrier@icescrum.com)
 */

package org.icescrum.plugins.components

import org.codehaus.groovy.grails.plugins.jasper.JasperExportFormat
import org.icescrum.components.UtilsWebComponents

class WindowTagLib {
  static namespace = 'is'

  def grailsApplication

  /**
   * Generate a window
   * The attribute "id" is obligatory
   */
  def window = { attrs, body ->


    def windowId = attrs.window ?: controllerName
    def type = attrs.type ?: 'window'

    // Check for content window
    def windowContent = (attrs.init) ? include(controller: windowId, action: attrs.init, params: params) : body()

    // Check for toolbar existence
    def titleBarContent = ''
    if (attrs.hasTitleBarContent) {
      if (attrs.type == 'widget') {
        titleBarContent = include(controller: windowId, action: 'titleBarContentWidget', params: params)
      } else {
        titleBarContent = include(controller: windowId, action: 'titleBarContent', params: params)
      }
    }

    // Check for toolbar existence
    def toolbarContent = ''
    if (attrs.hasToolbar) {
      if (attrs.type == 'widget') {
        toolbarContent = include(controller: windowId, action: 'toolbarWidget', params: params)
      } else {
        toolbarContent = include(controller: windowId, action: 'toolbar', params: params)
      }
    }

    if (attrs.shortcuts){
      attrs.help = attrs.help ?:""
      attrs.help += "<span class='help-shortcut-title'>${message(code:'is.ui.shortcut.title')}</span>"
      attrs.shortcuts.each{
        attrs.help += "<p class='keyboard-mappings'>"
        attrs.help += "<span class='code box-simple ui-corner-all'>${message(code:it.code)}</span>"
        attrs.help += "${message(code:it.text)}"
        attrs.help += "</p>"
      }
    }

    def params = [
            type: type,
            title: attrs.title ?: null,
            help: attrs.help ?: null,
            titleBarActions: attrs.titleBarActions ?: [
                    widgetable: attrs.widgetable ? true : false,
                    closeable: attrs.closeable ?: false,
                    maximizeable: attrs.maximizeable ?: false
            ],
            id: windowId,
            pushDisabled: attrs.pushDisabled,
            hasToolbar: attrs.hasToolbar,
            hasStatusbar: attrs.hasStatusbar,
            hasTitleBarContent: attrs.hasTitleBarContent,
            toolbar: toolbarContent,
            titleBarContent: titleBarContent,
            contentClass: attrs.contentClass,
            sortable: attrs.sortable?:false,
            height: attrs.height?:false,
            windowContent: windowContent
    ]
    out << g.render(template: '/components/window', plugin: 'icescrum-core-webcomponents', model: params)
  }

  /**
   * Generate a toolbar for a window
   */
  def toolbar = { attrs, body ->
    out << '<div class="box-navigation">'
    out << "<ul id='${attrs.type}-toolbar'>"
    out << body()
    out << '</ul>'
    out << '</div>'
  }

  /**
   * Generate a button for a toolbar
   */
  def iconButton = { attrs, body ->

    def uid = 'toolbar-' + (new Date().time);
    attrs."class" = "tool-button ${attrs."class" ?: ''} tool-button"
    attrs.remote = attrs.remote ?: 'true'

    if (UtilsWebComponents.rendered(attrs)) {
      out << '<li class=\"navigation-item\" uid="' << uid << '"' << (attrs.disablable ? 'disablable="' + attrs.disablable + '"' : '')
      if (attrs.style) {
        out << ' style="' << attrs.style << '"'
        attrs.remove('style')
      }
      out << '>'
      if (attrs.onload) {
        out << jq.jquery(null, attrs.onload);
        attrs.remove('onload');
      }

      if (attrs.shortcut && attrs.shortcut.key && attrs.shortcut.scope) {
        out << is.shortcut(key: attrs.shortcut.key, callback: "\$('#window-toolbar [uid=${uid}] > a').click();", scope: attrs.shortcut.scope, listenOn: "'#window-id-${attrs.shortcut.scope}'")
        attrs.remove('shortcut')
      }

      out << is.buttonNavigation(attrs, body())
      out << '</li>'
    }
  }

  def separatorSmall = { attrs, body ->
    if (UtilsWebComponents.rendered(attrs))
      out << "<li class=\"navigation-item separator-s\" ${attrs.elementId ? 'id=\"'+attrs.elementId+'\"':''}></li>"
  }

  /**
   * A separator in a toolbar, has the rendered** attributes.
   */
  def separator = {attrs, body ->
    if (UtilsWebComponents.rendered(attrs))
      out << "<li class=\"navigation-item separator\" ${attrs.elementId ? 'id=\"'+attrs.elementId+'\"':''}></li>"
  }

  def buttonNavigation = { attrs, body ->
    attrs."class" = attrs."class" ? attrs."class" : ""
    attrs."class" += attrs.button ? attrs.button : " button-n"
    attrs.remove("button");

    def str = "<span class=\"start\"></span><span class=\"content\">"

    if (attrs.icon) {
      attrs."class" += " button-ico button-" + attrs.icon
      str += "<span class=\"ico\"></span>"
      attrs.remove('icon')
    }

    if (!attrs.text)
      attrs.text = body().trim()

    str += "${attrs.text}</span><span class=\"end\">"
    if (attrs.dropmenu == 'true')
      str += "<span class=\"arrow\"></span>"

    str += "</span>"
    attrs.remove("text");

    if (attrs.remove('dialog'))
      out << is.remoteDialog(attrs, str).trim()
    else
      out << is.link(attrs, str).trim();

  }

  /**
   * Generate the side widget bar
   */
  def widgetBar = { attrs, body ->

    def widgetsList = []

    //Default displayed widgets
    grailsApplication.uIControllerClasses.each {controller ->
      if (controller) {
        def show = controller.getPropertyValue('widget')?.show
        if (show in Closure) {
          show.delegate = delegate
          show = show()
        }
        if (show){
          def widgetElement = [
              id: controller.getPropertyValue('id'),
              pushDisabled: grailsApplication.config?.icepush?.disabled?:true,
              hasToolbar: controller.getPropertyValue('widget')?.toolbar ?: false,
              closeable:(controller.getPropertyValue('widget')?.closeable == null) ? true : controller.getPropertyValue('widget').closeable,
              height:controller.getPropertyValue('widget')?.height ?: false,
              windowable:controller.getPropertyValue('window')? true : false,
              sortable:(controller.getPropertyValue('widget')?.sortable?.enable == null) ? true : controller.getPropertyValue('widget').sortable.enable,
              hasTitleBarContent: controller.getPropertyValue('widget')?.titleBarContent ?: false,
              title: message(code: controller.getPropertyValue('widget')?.title ?: ''),
              init: controller.getPropertyValue('widget')?.init ?: 'indexWidget'
          ]
          widgetsList.add(widgetElement)
        }
      }
    }
    //Widgets with sortable=false can be ordered si a position is set
    widgetsList.sort{it.sortable.position}
    out << g.render(template: '/components/widgetBar', plugin: 'icescrum-core-webcomponents', model: [widgetsList: widgetsList])
  }

  /**
   * Generate a widget using the is:window tag
   */
  def widget = { attrs, body ->
    attrs = attrs.attrs ?: attrs
    def params = [
            type: 'widget',
            title: attrs.title,
            titleBarActions: [
                    closeable: attrs.closeable ?: false,
                    windowable: attrs.windowable ?: false
            ],
            window: attrs.id,
            sortable:attrs.sortable,
            height:attrs.height,
            hasStatusbar: false,
            pushDisabled: attrs.pushDisabled,
            hasToolbar: attrs.hasToolbar,
            init: attrs.init
    ]
    out << is.window(params, {})
  }

  def remoteDialog = { attrs, body ->
    attrs.remoteDialog = true
    def result = dialogMethod(attrs)
    out << is.link(result, body)
  }

  def remoteDialogFunction = { attrs ->
    attrs.remoteDialog = true
    def result = dialogMethod(attrs)
    out << remoteFunction(result)
  }

  def dialog = { attrs, body ->
    out << "<div id='dialog'>${body()}</div>"
    out << dialogMethod(attrs)
  }

  private dialogMethod(attrs) {

    if (!UtilsWebComponents.rendered(attrs)) {
      return
    }

    def space = params.product ? 'product' : (params.team ? 'team' : null)
    if (space && !attrs.remove('noprefix')) {
      if (!attrs.params) {
        attrs.params = [(space): params.long(space)]
      } else if (Map.isAssignableFrom(attrs.params.getClass())) {
        attrs.params << [(space): params.long(space)]
      } else {
        attrs.params = "'product=${params.long('product')}&'+" + attrs.params
      }
    }

    if (attrs.title) {
      attrs.title = message(code: attrs.title)
    }

    def function = "\$('#dialog form').submit();"
    if (attrs.valid && attrs.valid.action) {
      function = remoteFunction(
              action: attrs.valid.action,
              controller: attrs.valid.controller,
              onSuccess: "${attrs.valid.onSuccess ? attrs.valid.onSuccess + ';' + '\$(\'#dialog\').dialog(\'close\');' : '\$(\'#dialog\').dialog(\'close\');'}  ",
              before: attrs.valid.before,
              id: attrs.valid.id,
              update: attrs.valid.update,
              params: "${attrs.valid.params ? attrs.valid.params + '+\'&\'+' : ''}jQuery('#dialog form:first').serialize()")
    }

    def function2 = "\$(this).dialog('close');"
    if (attrs.cancel) {
      function2 = remoteFunction(
              action: attrs.cancel.action,
              controller: attrs.cancel.controller,
              onSuccess: "${attrs.cancel.onSuccess ? attrs.cancel.onSuccess + ';' : ''} \$('#dialog').dialog('close'); ",
              before: attrs.cancel.before,
              id: attrs.cancel.id,
              update: attrs.cancel.update,
              params: "${attrs.cancel.params ? attrs.cancel.params + '+\'&\'+' : ''}jQuery('#dialog form:first').serialize()")
    }

    def buttonOk = message(code: "is.button.update")
    if (attrs.valid?.button) {
      buttonOk = message(code: attrs.valid.button)
    }

    def params = [
            closeOnEscape: attrs.closeOnEscape ?: true,
            closeText: attrs.closeText ?: "\'${message(code: 'is.dialog.close')}\'",
            dialogClass: attrs.className ?: null,
            draggable: attrs.draggable ?: false,
            height: attrs.height ?: null,
            hide: attrs.hideEffect ?: null,
            show: attrs.showEffect ?: null,
            maxHeight: attrs.maxHeight ?: null,
            maxWidth: attrs.maxWidth ?: null,
            minHeight: attrs.minHeight ?: null,
            minWidth: attrs.minWidth ?: null,
            modal: attrs.modal ?: true,
            position: attrs.position ?: "'top'",
            resizable: attrs.resizable ?: false,
            stack: attrs.stack ?: true,
            title: attrs.title ? "\'${attrs.title}\'" : null,
            width: attrs.width ?: 300,
            zindex: attrs.zindex ?: 1000,
            close: """function(ev, ui) { if(ev.keyCode && ev.keyCode === \$.ui.keyCode.ESCAPE){ ${attrs.cancel ? function2 : ''} } """ + (attrs.onClose ? attrs.onClose + ';' : '') + " \$(this).remove(); \$('.box-window').focus();}",
            buttons: attrs.buttons ? "{" + attrs.buttons + "}" : null
    ]

    def dialogCode = "\$('#dialog').dialog({"

    if (attrs.onSuccess) {
      dialogCode += "${attrs.onSuccess};"
    }

    if (attrs.valid || attrs.cancel) {
      params.buttons = "{'${message(code: "is.button.cancel")}': function(){${function2}},'${buttonOk}': function(){${function}}}"
    }
    attrs.remove('valid')
    attrs.remove('cancel')

    attrs.withTitlebar = attrs.withTitlebar ? attrs.withTitlebar.toBoolean() : false

    if (!attrs.withTitlebar)
      dialogCode += "dialogClass: 'no-titlebar',"

    attrs.remove('withTitlebar')

    dialogCode += params.findAll {k, v -> v != null}.collect {k, v -> "$k:$v"}.join(',')

    params.each {key, value ->
      attrs.remove(key)
    }
    attrs.remove('onSuccess')

    dialogCode += "});"

    if (attrs.focusable == null || attrs.focusable?.asBoolean()) {
      attrs.remove('focusable')
      dialogCode += "jQuery(\'.ui-dialog-buttonpane button:eq(1)\').focus();"
    } else {
      dialogCode += "jQuery(\'.ui-dialog-buttonpane button:eq(0)\').blur();"
    }



    if (attrs.onOpen) {
      dialogCode += attrs.onOpen
    }

    attrs.remove('onOpen');

    if (attrs.remoteDialog) {
      attrs.remove('remoteDialog')
      attrs.onSuccess = dialogCode
      attrs.remote = "true"
      attrs.update = "dialog"
      attrs.onLoaded = "\$(document.body).append('<div id=\\'dialog\\'></div>');"
      attrs.history = "false"
      return attrs
    } else {
      return jq.jquery(null, dialogCode)
    }
  }

  def onClose = {attrs, body ->
    def outClose = pageScope.onClose ?: ''
    if (body) {
      outClose << body()
      if (outClose)
        pageScope.outClose = outClose
    }
    outClose
  }

  def dialogButton = {attrs, body ->
    def outButtons = pageScope.dialogButton
    if (attrs) {
      def outButton = outButtons ? "$outButtons," : ''
      outButton << "{'${message(code: attrs.label ?: "is.button.cancel")}': function() {${attrs.callback ?: "\$(this).dialog('close');" }}"
      pageScope.outButtons = outButtons
    }
  }

  /**
   * Display an spinner on ajax call on the selected div id
   */
  def spinner = {attrs ->
    def type = attrs.id ?: 'spinner-app'
    out << '<div id="' + type + '" class="spinner"><div class="spinner-loading">' + message(code: "is.loading") + '</div></div>'
    out << jq.jquery(attrs, """
    \$(document).ajaxSend(function() { \$(document.body).css('cursor','progress');if(!\$.icescrum.maskSpinner){\$(".spinner").css('z-index', 999);\$(".spinner").show();}});
    \$(document).ajaxError(function(data) { \$(".spinner").fadeOut(); \$(".spinner").css('z-index', 995); \$(document.body).css('cursor','default'); });
    \$(document).ajaxComplete(function(e,xhr,settings){ if(xhr.status == 403){ $attrs.on403;}else if(xhr.status == 401){ $attrs.on401; }else if(xhr.status == 400){ $attrs.on400; }else if(xhr.status == 500){ $attrs.on500; } });
    \$(document).ajaxStop(function() { \$(".spinner").hide(); \$(document.body).css('cursor','default'); });
    """)
  }

  def shortcut = {attrs ->
    assert attrs.key
    assert attrs.callback

    if (attrs.scope)
      attrs.scope = "keydown.${attrs.scope}"
    else
      attrs.scope = "keydown"
    if (!attrs.listenOn) {
      attrs.listenOn = "document"
    }
    def escapedKey = attrs.key.replace('+', '').replace('.', '')
    def jqCode = "jQuery(${attrs.listenOn}).unbind('${attrs.scope}.${escapedKey}');"
    jqCode += "jQuery(${attrs.listenOn}).bind('${attrs.scope}.${escapedKey}','${attrs.key}',function(e){${attrs.callback}e.preventDefault();})"
    out << jq.jquery(null, jqCode);
  }

  /**
   * Implements the drag & drop import feature
   */
  def dropImport = { attrs, body ->
    assert attrs.id
    def jqCode = """jQuery('#window-content-${attrs.id}').dnd({
        dropHelper:'#${attrs.id}-drophelper',
        drop:function(event){
          var dt = event.dataTransfer;
          ${remoteFunction(controller: attrs.controller ?: controllerName, action: attrs.action ?: 'dropImport', params: "'product=${params.product}&data='+dt.text()", update: 'window-content-' + attrs.id)}
        }
      });"""
    out << g.render(template: '/components/dropHelper', plugin: 'icescrum-core-webcomponents', model: [id: attrs.id, description: message(code: attrs.description)])
    out << jq.jquery(null, jqCode)
  }

  /**
   *
   */
  def helpButton = { attrs, body ->

    assert attrs.id

    out << jq.jquery(null, {"\$('#${attrs.id}-list').dropmenu({top:15});"})

    out << "<li class=\"navigation-item\">"
    out << "<div class=\"dropmenu window-help\" id=\"${attrs.id}-list\">"

    def str = "<span class=\"help\">" + attrs.text + "</span>"

    out << str
    out << """<div class="dropmenu-content ui-corner-all content-help">
        ${body()}
      </div>"""

    out << "</div>"
    out << '</li>'
  }

  /**
   * Generate a drop menu that allow to choose a format for the report generation
   */
  def reportPanel = { attrs, body ->
    assert attrs.action

    def targetedFormats
    def supportedFormats = JasperExportFormat.collect { it.extension.toUpperCase() }

    switch (attrs.formats) {
      case 'ALL':
        targetedFormats = supportedFormats
        break
      case 'MSOFFICE':
        targetedFormats = ['DOCX', 'PPTX', 'XLS', 'XLSX']
        break
      case 'OPENOFFICE':
        targetedFormats = ['ODT', 'ODS']
        break
      default:
        targetedFormats = attrs.formats ?: ['PDF']
        break
    }
    def formatsLinks = '<ul><li class="first">' + targetedFormats.findAll {
      (it instanceof Collection && it[0] in supportedFormats) || (it in supportedFormats)
    }.asList().unique().collect {
      is.remoteDialog([
              action: attrs.action,
              controller: attrs.controller ?: controllerName,
              params: "'format=${it instanceof Collection ? it[0] : it}&${attrs.params ? attrs.params : ''}'",
              withTitlebar: "false",
              onClose: "\$.doTimeout('progressBar');",
              buttons: "'${message(code: 'is.button.close')}': function() { \$(this).dialog('close'); }",
              draggable: "false"
      ],
              '<div style="display:inline-block" class="file-icon ' + (it instanceof Collection ? it[0] : it).toLowerCase() + '-format">' +
                      (it instanceof Collection ? it[1] : it) + '</div>'
      )

    }.join('</li><li>') + '</li></ul>'

    out << is.panelButton(
            [
                    id: 'menu-report',
                    alt: attrs.text,
                    icon: 'print',
                    text: attrs.text
            ],
            formatsLinks
    )
  }
}
