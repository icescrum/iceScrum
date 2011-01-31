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
 */


package org.icescrum.plugins.components

import org.springframework.web.servlet.support.RequestContextUtils as RCU
import grails.converters.JSON
import grails.util.BuildSettingsHolder
import org.codehaus.groovy.grails.commons.GrailsClassUtils
import org.icescrum.components.UtilsWebComponents
import org.codehaus.groovy.grails.commons.DomainClassArtefactHandler
import org.springframework.context.MessageSourceResolvable
import org.codehaus.groovy.grails.web.util.StreamCharBuffer
import org.springframework.beans.SimpleTypeConverter

class FormTagLib {

  static namespace = 'is'

  def grailsApplication
  def grailsAttributes

  /**
   * Generate an autocomplete field
   */
  def autoComplete = { attrs, body ->
    assert attrs.elementId

    def id = attrs.elementId
    def sourceURL = createLink(controller: attrs.controller, action: attrs.action, elementId: attrs.elementId,id: attrs.id, params:params.product?[product:params.product]:params.team?[team:params.team]:null)
    def source = attrs.remove('source')
    if (source) {
      source = "function(request,response){$source(request,response,'$sourceURL',${attrs.remove('sourceOptions') as JSON});}"
    }

    def autoParams = [
            minLength: attrs.minLength ?: '2',
            source: source ?: "'${sourceURL}'",
            search: attrs.onSearch,
            select: attrs.onSelect,
            change: attrs.onChange,
            open: attrs.onOpen
    ]

    attrs.remove('onSearch')
    attrs.remove('onSelect')
    attrs.remove('onChange')
    attrs.remove('onOpen')
    attrs.remove('minLength')
    attrs.remove('controller')
    attrs.remove('action')
    attrs.remove('id')
    attrs.remove('elementId')

    def autoCode = "\$('#${id}').autocomplete({"
    autoCode += autoParams.findAll {k, v -> v}.collect {k, v ->
      " $k:$v"
    }.join(',')
    autoCode += "});"

    if (attrs.remove('init')) {
      autoCode += "\$('#$id').autocomplete('search' );"
    }

    out << jq.jquery(null, {autoCode})
    out << """<input id="${id}" name="${attrs.name ?: id}" ${attrs.collect {k, v -> " $k=\"$v\"" }.join('')} />"""
  }

  def autoCompleteChoose = { attrs, body ->

    assert attrs.name
    assert attrs.controller

    assert attrs.elementLabel

    attrs.resultId = attrs.resultId ?: 'searchid'

    def id = attrs.name.replaceAll("\\.", "-")
    def source = "choose-select-$id"
    def target = "choose-list-$id"

    out << g.render(template: '/components/autoCompleteChoose',plugin:'icescrum-core-webcomponents', model: [elementLabel: attrs.elementLabel, controller: attrs.controller, action: attrs.action,
            source: source, target: target, id: id, resultId: attrs.resultId, minLength: attrs.minLength])

  }

  def autoCompleteSkin = {attrs, body ->
    assert attrs.id

    def id = attrs.id
    def source = createLink(controller: attrs.controller, action: attrs.action, params:params.product?[product:params.product]:null)

    def autoParams = [
            minLength: attrs.minLength ?: '2',
            source: "'${source}'",
            search: "function(event,ui){${attrs.onSearch};}",
            select: "function(event,ui){${attrs.onSelect};}",
            change: "function(event,ui){${attrs.onChange};}"
    ]

    attrs.remove('source')
    attrs.remove('onSearch')
    attrs.remove('onSelect')
    attrs.remove('onChange')
    attrs.remove('minLength')
    attrs.remove('controller')
    attrs.remove('action')

    def autoCode = "\$('#${id}').autocomplete({"
    autoCode += autoParams.findAll {k, v -> v}.collect {k, v ->
      " $k:$v"
    }.join(',')
    autoCode += "});"

    if (attrs.disabled == false) {
      attrs.remove('disabled')
    }

    out << jq.jquery(null, {autoCode})
    out << is.input(attrs, body())
  }

  def autoCompleteSearch = { attrs, body ->
    out << is.autoComplete(controller: attrs.controller,
            action: attrs.action ?: 'index',
            minLength: attrs.minLength ?: '0',
            elementId: attrs.elementId,
            id: attrs.id,
            onSearch: "function(event,ui){if (\$(this).val().length > 0){\$('#search-ui .search-button').addClass('active-search');}else{\$('#search-ui .search-button').removeClass('active-search');}}",
            source: "\$.icescrum.autoCompleteSearch",
            sourceOptions: [update: attrs.update, before: attrs.before])
    out << is.shortcut(key:"ctrl+f", callback:"\$('#search-ui').mouseover();", scope:attrs.controller)
    out << is.shortcut(key:"esc", callback:"\$('#search-ui').mouseout();", scope:attrs.controller,listenOn:"'#${attrs.elementId}'")
  }

  /**
   * Generate a selectbox with the locales available in iceScrum
   */
  def localeSelecter = {attrs ->
    List locales = []
    def i18n
    if (grailsApplication.warDeployed) {
      i18n = grailsAttributes.getApplicationContext().getResource("WEB-INF/grails-app/i18n/").getFile().toString()
    } else {
      i18n = "$BuildSettingsHolder.settings.baseDir/grails-app/i18n"
    }
    //Default language
    locales <<  new Locale("en")
    new File(i18n).eachFile {
      def arr = it.name.split("[_.]")
      if (arr[1] != 'svn' && arr[1] != 'properties' && arr[0].startsWith('messages'))
        locales << (arr.length > 3 ? new Locale(arr[1], arr[2]) : arr.length > 2 ? new Locale(arr[1]) : new Locale(""))
    }

    attrs.from = locales
    attrs.value = RCU.getLocale(request)
    attrs.optionValue = {"${it.getDisplayName(it).capitalize()}"}
    out << is.select(attrs)
  }

  def select = { attrs ->

    if (!UtilsWebComponents.rendered(attrs)) {
      return
    }

    def selectOptions = [
            container: UtilsWebComponents.wrap(attr: (attrs.container), doubleQuote: true),
            style: UtilsWebComponents.wrap(attr: (attrs.styleSelect), doubleQuote: true),
            maxHeight: attrs.maxHeight ?: null,
            width: attrs.width ?: null,
            transferClasses: attrs.transferClasses ?: true,
            change: 'function(event, ui) {' + attrs.change + '}'
    ]

    def opts = selectOptions.findAll {k, v -> v != null}.collect {k, v -> " $k:$v" }.join(',')
    attrs.remove('container');
    attrs.remove('styleSelect');
    attrs.remove('maxHeight');
    attrs.remove('width');
    attrs.remove('change');
    def jqCode = ''

    if (attrs.disabled == null || attrs.disabled == 'false' || attrs.disabled == false) {
      def id = attrs.name.replace('.', '\\\\.')
      jqCode += " \$('#${id}').selectmenu({$opts});"
      out << jq.jquery(null, {jqCode})
    } else {
      attrs.disabled = true
    }

    def messageSource = grailsAttributes.getApplicationContext().getBean("messageSource")
    def locale = RCU.getLocale(request)
    def writer = out
    attrs.id = attrs.id ? attrs.id : attrs.name
    def from = attrs.remove('from')
    def keys = attrs.remove('keys')
    def icons = attrs.remove('icons')
    def optionKey = attrs.remove('optionKey')
    def optionValue = attrs.remove('optionValue')
    def value = attrs.remove('value')
    if (value instanceof Collection && attrs.multiple == null) {
        attrs.multiple = 'multiple'
    }
    if (value instanceof StreamCharBuffer) {
        value = value.toString()
    }
    def valueMessagePrefix = attrs.remove('valueMessagePrefix')
    def noSelection = attrs.remove('noSelection')
    if (noSelection != null) {
        noSelection = noSelection.entrySet().iterator().next()
    }
    def disabled = attrs.remove('disabled')
    if (disabled && Boolean.valueOf(disabled)) {
        attrs.disabled = 'disabled'
    }

    writer << "<select name=\"${attrs.remove('name')?.encodeAsHTML()}\" "
    // process remaining attributes
    outputAttributes(attrs)

    writer << '>'
    writer.println()

    if (noSelection) {
        renderNoSelectionOptionImpl(writer, noSelection.key, noSelection.value, value)
        writer.println()
    }

    // create options from list
    if (from) {
        from.eachWithIndex {el, i ->
            def keyValue = null
            writer << '<option '
            if (keys) {
                keyValue = keys[i]
                writeValueAndCheckIfSelected(keyValue, value, writer)
            }
            else if (optionKey) {
                def keyValueObject = null
                if (optionKey instanceof Closure) {
                    keyValue = optionKey(el)
                }
                else if (el != null && optionKey == 'id' && grailsApplication.getArtefact(DomainClassArtefactHandler.TYPE, el.getClass().name)) {
                    keyValue = el.ident()
                    keyValueObject = el
                }
                else {
                    keyValue = el[optionKey]
                    keyValueObject = el
                }
                writeValueAndCheckIfSelected(keyValue, value, writer, keyValueObject)
            }
            else {
                keyValue = el
                writeValueAndCheckIfSelected(keyValue, value, writer)
            }
            if (icons) {
                def iconValue = icons[i]
                writer << ' class="'+iconValue+'" '
            }
            writer << '>'
            if (optionValue) {
                if (optionValue instanceof Closure) {
                    writer << optionValue(el).toString().encodeAsHTML()
                }
                else {
                    writer << el[optionValue].toString().encodeAsHTML()
                }
            }
            else if (el instanceof MessageSourceResolvable) {
                writer << messageSource.getMessage(el, locale)
            }
            else if (valueMessagePrefix) {
                def message = messageSource.getMessage("${valueMessagePrefix}.${keyValue}", null, null, locale)
                if (message != null) {
                    writer << message.encodeAsHTML()
                }
                else if (keyValue) {
                    writer << keyValue.encodeAsHTML()
                }
                else {
                    def s = el.toString()
                    if (s) writer << s.encodeAsHTML()
                }
            }
            else {
                def s = el.toString()
                if (s) writer << s.encodeAsHTML()
            }
            writer << '</option>'
            writer.println()
        }
    }
    // close tag
    writer << '</select>'
  }

  def typed = { attrs ->
    def param = [
      allow:attrs.allow?'\''+attrs.allow+'\'':null,
      nocaps:attrs.nocaps?:null,
      allcaps:attrs.allcaps?:null,
      ichars:attrs.ichars?'\''+attrs.ichars+'\'':null,
    ]
    def jqTyped = '{'+param.findAll {k, v -> v != null}.collect {k, v -> " $k:$v"}.join(',')+'}'
    def jqCode = "\$('#${attrs.elementId}').${attrs.type}(${jqTyped});"
    out << jqCode
  }

  def input = {attrs, body ->
    assert attrs.id

    attrs."class" = attrs."class"?attrs."class"+' input':'input'

    def typedAttrs = attrs.typed?:null
    attrs.remove('typed')

    out << "<span id=\"${attrs.id}-field\" class=\"${attrs."class"}\">"
    out << "<span class=\"start\"></span>"
    out << "<span class=\"content\">"

    attrs.remove('class')

    out << textField(attrs, body())
    out << "</span>"
    out << "<span class=\"end\"></span>"
    out << "</span>"

    def jqCode = ''
    if (typedAttrs){
      typedAttrs.elementId = attrs.id
      jqCode = is.typed(typedAttrs)
    }
    jqCode += "\$('#${attrs.id}-field').input();"
    out << jq.jquery(null,jqCode)
  }

  def multiFilesUpload = {attrs ->
    assert attrs.name
    assert attrs.progress

    def enabled = UtilsWebComponents.enabled(attrs)

    out << """<div id=\"${attrs.elementId?:attrs.name}-field\" class=\"${attrs."class"?:''}inputfile\">"""
    if (attrs.bean)
      out << is.attachedFiles(bean:attrs.bean,name:attrs.name,deletable:enabled,controller:attrs.controller?:null,action:attrs.action?:null,params:attrs.params)
    out << """</div>"""

    if (enabled){

      def i18nP = [
              fileNotAccepted:'\''+message(code:'is.upload.error.fileNotAccepted')+'\'',
              fileAlReadyAdded:'\''+message(code:'is.upload.error.fileAlReadyAdded')+'\'',
              fileUploaded:'\''+message(code:'is.upload.complete')+'\'',
      ]
      def i18n = '{'+i18nP.findAll {k, v -> v != null}.collect {k, v -> " $k:$v"}.join(',')+'}'

      def paramP = [
            animated:attrs.progress.animated?:null,
            timer:attrs.progress.timer?:null,
            label:attrs.progress.label?'\''+attrs.progress.label+'\'':null,
            showOnCreate:attrs.progress.showOnCreate?:null,
            className:attrs.progress.className?'\''+attrs.progress.className+'\'':null,
            url:'\''+attrs.progress.url+'\'',
            startOn:attrs.progress.startOn?'\''+attrs.progress.startOn+'\'':null,
            startOnWhen:attrs.progress.startOnWhen?'\''+attrs.progress.startOnWhen+'\'':null,
            onComplete:attrs.progress.onComplete?'function(ui,data){'+attrs.progress.onComplete+'}':null
      ]
      def progress = '{'+paramP.findAll {k, v -> v != null}.collect {k, v -> " $k:$v"}.join(',')+'}'

      def paramM = [
              name:'\''+attrs.name+'\'',
              accept:attrs.accept as JSON,
              image: '\''+grailsApplication.config.grails.serverURL+'/'+is.currentThemeImage()+'buttons/choose-'+RCU.getLocale(request)+'.png\'',
              size:attrs.size?:null,
              multi:attrs.multi?:null,
              maxFiles:attrs.maxFiles?:null,
              onUploadComplete:attrs.onUploadComplete?'function(fileID){'+attrs.onUploadComplete+'}':null,
              onSelect:attrs.onSelect?'function(input,form){'+attrs.onSelect+'}':null,
              progress:progress?:null,
              urlUpload:'\''+attrs.urlUpload+'\'',
              i18n:i18n
      ]

      def multiFilesUploadP = '{'+paramM.findAll {k, v -> v != null}.collect {k, v -> " $k:$v"}.join(',')+'}'
      out << jq.jquery(null, "\$('#${attrs.elementId?:attrs.name}-field').multiFilesUpload(${multiFilesUploadP});")
    }
  }


  def progressBar = { attrs ->
     assert attrs.elementId

     def param = [
            animated:attrs.animated?:null,
            timer:attrs.timer?:500,
            label:attrs.label?'\''+attrs.label.encodeAsJavaScript()+'\'':null,
            showOnCreate:attrs.showOnCreate?:null,
            className:attrs.className?'\''+attrs.className+'\'':null,
            url:'\''+attrs.url+'\'',
            startOn:attrs.startOn?'\''+attrs.startOn+'\'':null,
            startOnWhen:attrs.startOnWhen?'\''+attrs.startOnWhen+'\'':null,
            onComplete:attrs.onComplete?'function(ui,data){'+attrs.onComplete+'}':null,
            iframe:attrs.iframe?:null,
            iframeSrc:attrs.iframeSrc?'\''+attrs.iframeSrc+'\'':null,
            startValue:attrs.startValue?:0,
            params:attrs.params?:null,
            timerID:attrs.timerID?:null
     ]
     out << "<span id='${attrs.elementId}'></span>"
     def progressOptions = '{'+param.findAll {k, v -> v != null}.collect {k, v -> " $k:$v"}.join(',')+'}'
     def progressCode = "\$('#${attrs.elementId}').progress(${progressOptions});"
     out << jq.jquery(null,progressCode)
  }

  def attachedFiles = { attrs ->
    assert attrs.bean

    attrs.bean?.attachments?.each{ attachment ->

      out << """
      <div class="is-multifiles-checkbox" id="file-${attachment.id}">
            <div class="is-multifiles-filename file-icon ${attachment.ext.toLowerCase()}-format" style="display: inline-block; margin-left: 0px; ${attrs.width?'width:'+attrs.width+'px;':''}">
              <a href="${g.createLink(controller:attrs.controller?:controllerName,action:attrs.action?:'download',id:attachment.id,params:attrs.params)}"><span title="${attachment.filename}">${is.truncated(size:attrs.size?:23){attachment.filename}}</span></a>
            </div>
      </div>"""
      if (attrs.deletable){
        out << jq.jquery(null,"\$('#file-${attachment.id}').checkBoxFile('${GrailsClassUtils.getShortName(attrs.bean.class).toLowerCase()}.${attrs.name}',${attachment.id});")
      }
    }
  }

  def radio = {attrs, body ->
    assert attrs.id

    def from
    if (!attrs.from) {
      from = [(message(code: 'is.yes')): 1, (message(code: 'is.no')): 0]
      if (attrs.value)
        attrs.value = 1
      else
        attrs.value = 0
    }else{
      from = attrs.from
    }
    attrs.remove('from')
    out << "<span id='${attrs.id}' class='radio'>"
    from.eachWithIndex {key, value, index ->
      def checked = false
      if (value == attrs.value) checked = true
      out << "<span class='${attrs.id}-${index}'>${key}</span>"
      out << g.radio(onClick: attrs.onClick ?: '', name: attrs.name, value: value, checked: checked, id: "${attrs.id}-${index}")
      out << jq.jquery(null, "\$('input:radio[id=${attrs.id}-${index}]').checkBox();")
    }
    out << "</span>"

  }

  def checkbox = {attrs, body ->
    out << "<span class='radio'>"
    out << g.checkBox(onClick: attrs.onClick ?: '', name: attrs.name, value: attrs.value, "class":"checkbox")
    out << attrs.label.encodeAsHTML()
    out << jq.jquery(null, "\$('.checkbox').checkBox();")
    out << "</span>"

  }

  def area = {attrs, body ->
    assert attrs.id

    def classe = ''
    def classes = "area${attrs.rich?'-rich':''}"
    def isMedium = (attrs.remove("medium") == "true")
    def isLarge = (attrs.remove("large") == "true")

    if (isMedium)
      classes = "area-medium"

    if (isLarge)
      classes = "area-large"

    if (isMedium || isLarge)
      classe = "area"

    out << "<span class=\"${classe} ${classes}\" id=\"${attrs.id}-field\" style=\"${attrs.width?'width:'+attrs.width:''}\">"
    if (attrs.rich){
      if (attrs.rich.disabled){
        if (attrs.rich.fillWidth){
          def jqCode = "jQuery('#${attrs.id}-field').width(jQuery('#${attrs.id}-field').parent().width() - ${attrs.rich.margin?:0});"
          out << jq.jquery(null, jqCode)
        }
        out << wikitext.renderHtml(markup:"Textile",{attrs.value?.replace('<!--','')})
      }
      else{
        attrs.rich.id = attrs.id
        attrs.rich.name = attrs.name
        out << markitup.editor(attrs.rich, {attrs.value})
      }
    }else{
      out << "<span class=\"start\"></span>"
      out << "<span class=\"content\">"
      out << textArea(attrs, body())
      out << "</span>"


      out << "<span class=\"end\"></span>"
    }
    out << "</span>"

    if (!attrs.rich)
      out << jq.jquery(null, "\$('#${attrs.id}-field').input({className:\"${classes}\"});")
  }

  def password = {attrs, body ->
    out << "<span class=\"input\" id=\"${attrs.id}-field\">"
    out << "<span class=\"start\"></span>"
    out << "<span class=\"content\">"
    out << passwordField(attrs, body())
    out << "</span>"
    out << "<span class=\"end\"></span>"
    out << "</span>"
    out << jq.jquery(null, "\$('#${attrs["id"]}-field').input();")
  }

  def boxTile = {attrs, body ->
    out << "<div class=\"box-title\">"
    out << "<span class=\"start\"></span>"
    out << "<p class=\"content\">"
    out << body()
    out << "</p>"
    out << "<span class=\"end\"></span>"
    out << "</div>"
  }

  def color = {attrs, body ->
    assert attrs.id

    attrs."class" = attrs."class"?attrs."class"+' color {hash:true}':'color {hash:true}'
    def value = attrs.value ?: "#FFF"
    def id = attrs.id
    out << "<span class=\"input\" id=\"${attrs.id}-field\">"
    out << "<span class=\"start\"></span>"
    out << "<span class=\"content\">"
    out << textField(attrs, body())
    out << "<input class=\"reset\" type=\"button\" onClick=\"\$('#colorinput').val('${value}'); updateColor(\$('#${id}').val()); \$('#${id}').css('color', '#000000');\" value=\"${message(code: 'is.button.reset')}\"/>"
    out << "</span>"
    out << "<span class=\"end\"></span>"
    out << "</span>"

    out << jq.jquery(null, "\$('#${attrs["id"]}-field').input();")
  }

  def fieldInput = {attrs, body ->
    attrs."class" = attrs."class"?attrs."class"+' field-input clearfix':'field-input clearfix'
    if (attrs.remove("noborder") == "true")
      attrs."class" += " field-noseparator"
    out << "<p class=\"${attrs."class"}\" ${attrs.style?'style=\"'+attrs.style+'\"':''}>"
    out << "<label for=\"${attrs."for"}\">${message(code: attrs.label)}${attrs.optional ? '<span class="optional"> ('+message(code: 'is.optional')+')</span>'  : ''}</label>"
    out << body()
    out << "</p>"
  }

   def fieldFile = {attrs, body ->
    attrs."class" = attrs."class"?attrs."class"+' field-input clearfix':'field-input clearfix'
    if (attrs.remove("noborder") == "true")
      attrs."class" += " field-noseparator"
    out << "<div class=\"${attrs."class"}\">"
    out << "<label for=\"${attrs."for"}\">${message(code: attrs.label)}${attrs.optional ? '<span class="optional"> ('+message(code: 'is.optional')+')</span>'  : ''}</label>"
    out << body()
    out << "</div>"
  }

  def fieldRadio = {attrs, body ->
    if (!UtilsWebComponents.rendered(attrs)) {
      return
    }
    attrs."class" = attrs."class"?attrs."class"+' field-input clearfix':'field-input clearfix'
    if (attrs.remove("noborder") == "true")
      attrs."class" += " field-noseparator"
    out << "<p class=\"${attrs."class"}\">"
    out << "<label for=\"${attrs."for"}\">${message(code: attrs.label)}${attrs.optional ? '<span class="optional"> ('+message(code: 'is.optional')+')</span>'  : ''}</label>"
    out << body()
    out << "</p>"
  }

  def fieldDatePicker = {attrs, body ->
    if (attrs."for") attrs."for" = "datepicker-" + attrs."for"
    out << is.fieldInput(attrs, body)
  }

  def fieldTimePicker = {attrs, body ->
    if (attrs."for") attrs."for" = "timepicker-" + attrs."for"
    out << is.fieldInput(attrs, body)
  }

  def fieldSelect = {attrs, body ->
    attrs."class" = attrs."class"?attrs."class"+' field-select clearfix':"field-select clearfix"
    if (attrs.remove("noborder") == "true")
      attrs."class" += " field-noseparator"
    out << "<p class=\"${attrs."class"}\">"
    out << "<label for=\"${attrs."for"}\">${message(code: attrs.label)}${attrs.optional ? '<span class="optional"> ('+message(code: 'is.optional')+')</span>'  : ''}</label>"
    out << "<span class=\"selectmenu\">" + body() + "</span>"
    out << "</p>"
  }

  def fieldList = {attrs, body ->
    attrs."class" = attrs."class"?attrs."class"+' field-list clearfix':"field-list clearfix"
    if (attrs.remove("noborder") == "true")
      attrs."class" += " field-noseparator"
    out << "<p class=\"${attrs."class"}\">"
    out << "<label for=\"${attrs."for"}\">${message(code: attrs.label)}${attrs.optional ? '<span class="optional"> ('+message(code: 'is.optional')+')</span>'  : ''}</label>"
    out << body()
    out << "</p>"
  }

  def list = {attrs, body ->
    out << "<span class=\"list\">" + g.select(attrs, body()) + "</span>"
  }


  def fieldCheckbox = {attrs, body ->
    attrs."class" = attrs."class"?attrs."class"+' field-checkbox clearfix':"field-checkbox clearfix"
    if (attrs.remove("noborder") == "true")
      attrs."class" += " field-noseparator"
    out << "<p class=\"${attrs."class"}\">"
    out << "<label for=\"${attrs."for"}\">${message(code: attrs.label)}${attrs.optional ? '<span class="optional"> ('+message(code: 'is.optional')+')</span>'  : ''}</label>"
    out << "<span class=\"checkbox\">" + body() + "</span>"
    out << "</p>"
  }

  def fieldArea = {attrs, body ->
    attrs."class" = attrs."class"?attrs."class"+' field-area clearfix':"field-area clearfix"
    if (attrs.remove("noborder") == "true")
      attrs."class" += " field-noseparator"
    out << "<p class=\"${attrs."class"}\">"
    out << "<label for=\"${attrs."for"}\">${message(code: attrs.label)}${attrs.optional ? '<span class="optional"> ('+message(code: 'is.optional')+')</span>'  : ''}</label>"
    out << body()
    out << "</p>"
  }

  def fieldColor = {attrs, body ->
    attrs."class" = attrs."class"?attrs."class"+' field-color clearfix':"field-color clearfix"
    if (attrs.remove("noborder") == "true")
      attrs."class" += " field-noseparator"
    out << "<p class=\"${attrs."class"}\">"
    out << "<label for=\"${attrs."for"}\">${message(code: attrs.label)}${attrs.optional ? '<span class="optional"> ('+message(code: 'is.optional')+')</span>'  : ''}</label>"
    out << "<span class=\"color\">" + body() + "</span>"
    out << "</p>"
  }

  def fieldset = {attrs, body ->
    if (attrs.title) {
      attrs.title = message(code: attrs.title)
    }
    if (attrs.description) {
      attrs.description = message(code: attrs.description)
    }
    attrs."class" = attrs."class"?attrs."class"+' panel ui-corner-all':"panel ui-corner-all"
    if (attrs.remove('nolegend'))
      attrs."class" += " panel-nolegend"
    out << "<div ${attrs.id?'id=\"'+attrs.id+'\"':''} class=\"${attrs."class"}\" ${attrs.description?'description=\"'+attrs.description+'\"':''}>"
    out << "<h3 class=\"panel-title\">${attrs.title}</h3>"
    out << body()
    out << "</div>"
  }

  def buttonBar = {attrs, body ->
    if (!attrs.id)
      attrs.id = 'button-bar'

    pageScope.parent = "true"

    out << "<div class=\"field-buttons\" id=\"${attrs.id}\">"
    out << "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\">"
    out << "<tr>"
    out << "<td width=\"50%\">&nbsp;</td>"
    out << body()
    out << "<td width=\"50%\">&nbsp;</td>"
    out << "</tr>"
    out << "</table>"
    out << "</div>"
  }

  def fieldInformation = {attrs, body ->
    attrs."class" = attrs."class"?attrs."class"+' field-information':"field-information"
    if (attrs.remove("nobordertop") == "true")
      attrs."class" += " field-information-nobordertop"
    out << "<${attrs.div?'div':'p'} class=\"${attrs."class"}\">${body()}</${attrs.div?'div':'p'}>"
  }

  def buttonBarItem = {attrs, body ->
    out << "<td>" + body() + "</td>"
  }

  def button = {attrs, body ->
    def content
    def str = ""
    attrs."class" = attrs."class" ? attrs."class" : ""
    attrs.button = attrs.button ? attrs.button : "button-s"

    def the_body = attrs.value ? attrs.remove("value") : body()

    def history = attrs.history ? attrs.history.toBoolean() : true

    if (attrs.type == "submit") {
      attrs.remove('history')
      def generateId = "button" + new Date().time
      def onClick = '$(\'#' + generateId + '\').click();'
      attrs.id = generateId
      attrs.name = generateId
      content = "<span class=\"${attrs.button} clearfix\">"
      content += "<span class=\"start\" onClick=\"" + onClick + "\"></span>"
      content += "<span class=\"content\" onClick=\"" + onClick + "\">" + the_body + "</span>"
      content += "<span class=\"end\" onClick=\"" + onClick + "\"></span>"
      content += "<span class=\"mask-submit\">"

      if (history){
          def fragment
        if (attrs.targetLocation){
           fragment = "${attrs.targetLocation}"
        }else{
          fragment = "${controllerName}${params.id?'/'+params.id:''}"
        }
        attrs.onSuccess = "${attrs.onSuccess ?: ''}; \$.icescrum.addHistory('${fragment}')";
        attrs.onClick = "${attrs.onclick ?: ''}; return false;"
      }

      content += g.submitToRemote(attrs)
      content += "</span>"
      content += "</span>"
      str += content
    } else if (attrs.type == "link") {
      content = "<span class=\"start\"></span><span class=\"content\">${the_body}</span><span class=\"end\"></span>"
      attrs.remove("type");
      attrs."class" += " " + attrs.button + " clearfix"
      attrs.remove("button")
      str += is.link(attrs, content)
    } else if (attrs.type == "submitToRemote") {
      attrs.remove('history')
      if (history){
          def fragment
        if (attrs.targetLocation){
           fragment = "${attrs.targetLocation}"
        }else{
          fragment = "${controllerName}${params.id?'/'+params.id:''}"
        }
        attrs.onSuccess = "${attrs.onSuccess ?: ''}; \$.icescrum.addHistory('${fragment}')";
        attrs.onClick = "${attrs.onclick ?: ''}; return false;"
      }

      def onClick = '$(this).parent().find(\'input\').click();'
      content = "<span class=\"${attrs.button} clearfix\">"
      attrs.remove("type");
      attrs.remove("button");
      content += "<span class=\"start\" onClick=\"" + onClick + "\"></span>"
      content += "<span class=\"content\" onClick=\"" + onClick + "\">" + the_body + "</span>"
      content += "<span class=\"end\" onClick=\"" + onClick + "\"></span>"
      content += "<span class=\"mask-submit\">"
      content += g.submitToRemote(attrs)
      content += "</span>"
      content += "</span>"
      str += content
    }

    try {
      if (pageScope.parent)
        str = "<td>" + str + "</td>"
    } catch (e) {}

    out << str
  }

  def browser = {attrs, body ->
    out << g.render(template: '/components/browser',plugin:'icescrum-core-webcomponents', model: [
            actionButton: body(),
            initContent: attrs.remove('initContent'),
            controller: attrs.remove('controller'),
            noFinder:attrs.remove('noFinder') == 'true',
            actionColumn: attrs.actionColumn,
            name: attrs.name,
            titleLabel:attrs.titleLabel,
            browserLabel: attrs.browserLabel,
            detailsLabel: attrs.detailsLabel
    ])
  }

  def editable = { attrs,body ->

    attrs.onExit = attrs.onExit ?: 'submit'
    attrs.type = attrs.type ?: 'text'
    def finder = ""
    def data = "return value;"

    if (attrs.type == 'text'){
      finder = "\$(original).find('input').val()"
      if (attrs.typed){
        attrs.typed.elementId = attrs.on
        data = is.typed(attrs.typed)+' '+data;
      }
    }
    else if (attrs.type == 'textarea'){
      finder = "\$(original).find('textarea').val()"
    }
    else if (attrs.type == 'datepicker'){
      finder = "\$(original).find('textarea').val()"
    }
    else if (attrs.type == 'richarea'){
      finder = "\$(original).find('textarea').val()"
    }
    else if (attrs.type == 'selectui'){
      finder = "\$(original).find('select').children('option:selected').text()"
      data = "return {${attrs.values},'selected':value};"
    }

     else if (attrs.type == 'select'){
      finder = "\$(original).find('select').children('option:selected').text()"
      data = "return {${attrs.values},'selected':value};"
    }

    def jqCode = """
                \$('${attrs.on}').hover(function(){
                   \$(this).addClass("editable-hover");
                 },function(){
                   \$(this).removeClass("editable-hover");
                 });
                \$('${attrs.on}').editable('${createLink(action:attrs.action,controller:attrs.controller,params:attrs.params)}',{
                    type:'${attrs.type}',
                    select: ${attrs.highlight?:false},
                    data : function(value, settings) {${attrs.before?:''} ${data}},
                    onsubmit:function(settings, original){ if (${finder} == original.revert) {original.reset(); ${attrs.cancel?:''} return false;}},
                    submitdata : function(value, settings) {return {'id':${attrs.findId}}},
                    callback:function(value, settings) { ${attrs.callback?:''} return value;},
                    onblur:'${attrs.onExit}'
                });
             """
    if (attrs.wrap){
      out << jq.jquery(null,jqCode)
    }else{
      out << jqCode
    }
  }

  def datePicker = { attrs, body ->
    def jqCode = ''
    def wrapDateFormat = {value ->
      if (value == null) return null
      if (value instanceof Date) {
        return 'new Date(' + formatDate(date: value, format: 'yyyy,M-1,d') + ')'
      } else if ((value instanceof String || value instanceof GString) && (value.isNumber() || value.indexOf('new Date') != -1))
        return value
      else
        return UtilsWebComponents.wrap(value)
    }

    if (attrs.onSelect)
      attrs.onSelect = "function(dateText, inst) {${attrs.onSelect}}"

    def args = [
            minDate: wrapDateFormat(attrs.minDate),
            maxDate: wrapDateFormat(attrs.maxDate),
            defaultDate: wrapDateFormat(attrs.defaultDate),
            dateFormat: UtilsWebComponents.wrap(attrs.dateFormat),
            changeMonth: attrs.changeMonth,
            changeYear: attrs.changeYear,
            onSelect: attrs.onSelect,
            firstDay: 1
    ]
    if (attrs.mode && attrs.mode == 'inline') {
      out << "<input type=\"hidden\" id=\"datepicker-input-${attrs.id}\" name=\"${attrs.name}\" class=\"datePicker\" />"
      out << "<div id=\"datepicker-${attrs.id}\" class=\"datePicker\"></div>"
      args.altField = UtilsWebComponents.wrap("#datepicker-input-${attrs.id}")
      args.altFormat = UtilsWebComponents.wrap("yy-mm-dd")
    } else if (attrs.mode && attrs.mode == 'read-input') {

      def argsInput = [
              id: "datepicker-" + attrs.id,
              name: attrs.name,
              class: "datePicker"
      ]
      out << is.input(argsInput, "")
      // out << "<input type=\"text\" id=\"datepicker-${attrs.id}\" name=\"${attrs.name}\" class=\"datePicker\" value=\"\"/>"

      jqCode += "\$('#datepicker-${attrs.id}').attr('readonly', true);"
      args.dateFormat = UtilsWebComponents.wrap(message(code:'is.date.jquery'))
    } else {
      out << "<input type=\"text\" id=\"datepicker-${attrs.id}\" name=\"${attrs.name}\" class=\"datePicker\" />"
    }
    def opts = args.findAll {k, v -> v != null}.collect {k, v -> " $k:$v"}.join(',')
    jqCode += "\$('#datepicker-${attrs.id}').datepicker({${opts}});"
    jqCode += "\$('#datepicker-${attrs.id}').datepicker('setDate', ${args.defaultDate});"
    if (attrs.disabled && (attrs.disabled == 'true' || attrs.disabled == true))
      jqCode += "\$('#datepicker-${attrs.id}').datepicker('disable');"
    out << jq.jquery(null, jqCode)
  }

  def timePicker = { attrs, body ->

    assert attrs.id

    def jqCode = ''

    if (attrs.onSelect)
      attrs.onSelect = "function(dateText, inst) {${attrs.onSelect}}"

    def args = [
            ampm: attrs.ampm?:null,
            showHour:attrs.showHour?:null,
            showMinute:attrs.showMinute?:null,
            showSecond:attrs.showSecond?:null,
            stepHour: attrs.stepHour?:null,
            stepMinute: attrs.stepMinute?:null,
            stepSecond: attrs.stepSecond?:null,
            hour: attrs.hour?:null,
            minute: attrs.minute?:null,
            second: attrs.second?:null,
            hourGrid: attrs.hourGrid?:null,
            minuteGrid: attrs.minuteGrid?:null,
            secondGrid: attrs.secondGrid?:null,
            timeFormat: attrs.timeFormat?UtilsWebComponents.wrap(attrs.timeFormat):null
    ]

    def argsInput = [
            id: "timepicker-" + attrs.id,
            name: attrs.name,
            value: attrs.value,
            class: "datePicker"
    ]

    out << is.input(argsInput, "")

    if (attrs.mode && attrs.mode == 'read-input') {
      jqCode += "\$('#timepicker-${attrs.id}').attr('readonly', true);"
    }

    def opts = args.findAll {k, v -> v != null}.collect {k, v -> " $k:$v"}.join(',')
    jqCode += "\$('#timepicker-${attrs.id}').timepicker({${opts}});"

    if (attrs.disabled && (attrs.disabled == 'true' || attrs.disabled == true))
      jqCode += "\$('#timepicker-${attrs.id}').timepicker('disable');"
    out << jq.jquery(null, jqCode)
  }

  def accordion = { attrs, body ->
    assert attrs.id

    def params = [
            id: attrs.id,
            disabled: !UtilsWebComponents.enabled(attrs) ?: false,
            active: attrs.active ?: null,
            animated: attrs.animated ?: null,
            autoHeight: attrs.autoHeight ?: true,
            clearStyle: attrs.clearStyle ?: false,
            collapsible: attrs.collapsible ?: false,
            event: attrs.event ?: null,
            fillSpace: attrs.fillSpace ?: false,
            header: attrs.header ?: null,
            icons: attrs.icons ?: null,
            navigation: attrs.navigation ?: false,
            navigationFilter: attrs.navigationFilter ?: null
    ]

    out << "<div id='${attrs.id}'>"
    out << body()
    out << "</div>"

    params.remove('id')

    def jqCode = "\$('#${attrs.id}').accordion({"
    jqCode += params.findAll {k, v -> v != null}.collect {k, v -> "$k:$v"}.join(',')
    jqCode += "});"
    out << jq.jquery(null, jqCode);
  }

  def accordionSection = {attrs, body ->
    assert attrs.title

    out << "<h3><a href='#'>${message(code: attrs.title)}</a></h3>"
    out << "<div>"
    out << body()
    out << "</div>"
  }


  /**
   * Dump out attributes in HTML compliant fashion
   */
  void outputAttributes(attrs) {
      attrs.remove('tagName') // Just in case one is left
      def writer = getOut()
      attrs.each {k, v ->
          writer << "$k=\"${v.encodeAsHTML()}\" "
      }
  }

  def renderNoSelectionOption = {noSelectionKey, noSelectionValue, value ->
      renderNoSelectionOptionImpl(out, noSelectionKey, noSelectionValue, value)
  }

  def renderNoSelectionOptionImpl(out, noSelectionKey, noSelectionValue, value) {
      // If a label for the '--Please choose--' first item is supplied, write it out
      out << "<option value=\"${(noSelectionKey == null ? '' : noSelectionKey)}\"${noSelectionKey == value ? ' selected="selected"' : ''}>${noSelectionValue.encodeAsHTML()}</option>"
  }

  def typeConverter = new SimpleTypeConverter()
  private writeValueAndCheckIfSelected(keyValue, value, writer) {
      writeValueAndCheckIfSelected(keyValue, value, writer, null)
  }

  private writeValueAndCheckIfSelected(keyValue, value, writer, el) {

      boolean selected = false
      def keyClass = keyValue?.getClass()
      if (keyClass.isInstance(value)) {
          selected = (keyValue == value)
      }
      else if (value instanceof Collection) {
          // first try keyValue
          selected = value.contains(keyValue)
          if (! selected && el != null) {
              selected = value.contains(el)
          }
      }
      else if (keyClass && value) {
          try {
              value = typeConverter.convertIfNecessary(value, keyClass)
              selected = (keyValue == value)
          }
          catch (Exception) {
              // ignore
          }
      }
      writer << "value=\"${keyValue}\" "
      if (selected) {
          writer << 'selected="selected" '
      }
  }

}
