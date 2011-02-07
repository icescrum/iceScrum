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
 */

package org.icescrum.plugins.components

import org.icescrum.components.UtilsWebComponents

class TooltipTagLib {
  static namespace = 'is'

  def tooltip = { attrs ->
    assert attrs."for"
    assert (attrs.contentText || attrs.contentTitleText)

    def tooltipCode

    tooltipCode = "\$('${attrs."for"}').qtip({"

    //Arguments to define content of the tooltip
    def contentTitle = [
            text: attrs.contentTitleText ? "\"${attrs.contentTitleText.encodeAsJavaScript()}\"" : null,
            button: attrs.contentTitleButton ? "\"${attrs.contentTitleButton}\"" : null,
    ]

    def content = [
            prerender: attrs.contentPrerender ?: null,
            text: attrs.contentText ? "\"${attrs.contentText.encodeAsJavaScript()}\"" : null,
            url: attrs.contentUrl ? "'${attrs.contentUrl}'" : null,
            data: attrs.contentData ?: null,
            method: attrs.contentMethod ? "'${attrs.contentMethod}'" : null,
            title: contentTitle
    ]

    //Begin Arguments to define position
    def positionCorner = [
            target: attrs.positionCornerTarget ? "'${attrs.positionCornerTarget}'" : null,
            tooltip: attrs.positionCornerTooltip ? "'${attrs.positionCornerTooltip}'" : null
    ]

    def positionAdjust = [
            x: attrs.positionAdjustX ?: null,
            y: attrs.positionAdjustY ?: null,
            mouse: attrs.positionAdjustMouse ?: null,
            screen: attrs.positionAdjustScreen ?: null,
            scroll: attrs.positionAdjustScroll ?: null,
            resize: attrs.positionAdjustResize ?: null
    ]
    def position = [
            target: !attrs.positionTarget ? null : attrs.positionTarget,
            type: attrs.positionType ? "'${attrs.positionType}'" : null,
            container: !attrs.positionContainer ? null : attrs.positionContainer,
            corner: positionCorner,
            adjust: positionAdjust
    ]

    //Arguments to define how the tooltip is shown
    def showWhen = [
            target: !attrs.showWhenTarget ? null : attrs.showWhenTarget,
            event: attrs.showWhenEvent ? "'${attrs.showWhenEvent}'" : null
    ]
    def showEffect = [
            type: attrs.showEffectType ? "'${attrs.showEffectType}'" : null,
            length: !attrs.showEffectLength ? null : attrs.showEffectLength
    ]
    def show = [
            delay: !attrs.showDelay ? null : attrs.showDelay,
            solo: attrs.showSolo ?: null,
            ready: attrs.showReady ?: null,
            when: showWhen,
            effect: showEffect
    ]

    //Arguments to define how the tooltip is hidden
    def hideWhen = [
            target: !attrs.hideWhenTarget ? null : attrs.hideWhenTarget,
            event: attrs.hideWhenEvent ? "'${attrs.hideWhenEvent}'" : null
    ]
    def hideEffect = [
            type: attrs.hideEffectType ? "'${attrs.hideEffectType}'" : null,
            length: !attrs.hideEffectLength ? null : attrs.hideEffectLength
    ]
    def hide = [
            delay: attrs.hideDelay ? "${attrs.hideDelay}" : null,
            fixed: attrs.hideFixed ?: null,
            when: hideWhen,
            effect: hideEffect
    ]

    //Arguments to define how the tooltip is hidden
    def styleWidth = [
            min: !attrs.styleWidthMin ? null : attrs.styleWidthMin,
            max: attrs.styleWidthMax ? "'${attrs.styleWidthMax}'" : null
    ]
    def styleBorder = [
            width: !attrs.styleBorderWidth ? null : attrs.styleBorderWidth,
            radius: !attrs.styleBorderRadius ? null : attrs.styleBorderRadius,
            color: attrs.styleBorderColor ? "'${attrs.styleBorderColor}'" : null
    ]

    def styleTypeSize = [
            x: !attrs.styleTypeSizeX ? null : attrs.styleTypeSizeX,
            y: !attrs.styleTypeSizeY ? null : attrs.styleTypeSizeY,
    ]

    def styleTip = [
            corner: attrs.styleTipCorner ? "'${attrs.styleTipCorner}'" : null,
            color: attrs.styleTipColor ? "'${attrs.styleTipColor}'" : null,
            size:styleTypeSize
    ]

    def styleClasses = [
            target: attrs.styleClassesTarget ? "'${attrs.styleClassesTarget}'" : null,
            tooltip: attrs.styleClassesTooltip ? "'${attrs.styleClassesTooltip}'" : null,
            tip: attrs.styleClassesTip ? "'${attrs.styleClassesTip}'" : null,
            title: attrs.styleClassesTitle ? "'${attrs.styleClassesTitle}'" : null,
            content: attrs.styleClassesContent ? "'${attrs.styleClassesContent}'" : null,
            active: attrs.styleClassesActive ? "'${attrs.styleClassesActive}'" : null
    ]
    def style = [
            name: attrs.styleName ? "'${attrs.styleName}'" : null,
            title: attrs.styleTitle ? "${attrs.styleTitle}" : null,
            button: attrs.styleButtonCss ? "'${attrs.styleButtonCss}'" : null,
            width: styleWidth,
            border: styleBorder,
            tip: attrs.styleTip?"'${attrs.styleTip}'":styleTip,
            classes: styleClasses
    ]

    def api = [
            beforeRender: attrs.apiBeforeRender ? "${attrs.apiBeforeRender}" : null,
            onRender: attrs.apiOnRender ? "${attrs.apiOnRender}" : null,
			beforePositionUpdate: attrs.apiBeforePositionUpdate ? "${attrs.apiBeforePositionUpdate}" : null,
			onPositionUpdate: attrs.apiOnPositionUpdate ? "${attrs.apiOnPositionUpdate}" : null,
			beforeShow: attrs.apiBeforeShow ? "${attrs.apiBeforeShow}" : null,
			onShow: attrs.apiOnShow ? "${attrs.apiOnShow}" : null,
			beforeHide: attrs.apiBeforeHide ? "${attrs.apiBeforeHide}" : null,
			onHide: attrs.apiOnHide ? "${attrs.apiOnHide}" : null,
			beforeContentUpdate: attrs.apiBeforeContentUpdate ? "${attrs.apiBeforeContentUpdate}" : null,
			onContentUpdate: attrs.apiOnContentUpdate ? "${attrs.apiOnContentUpdate}" : null,
			beforeContentLoad: attrs.apiBeforeContentLoad ? "${attrs.apiBeforeContentLoad}" : null,
			onContentLoad: attrs.apiOnContentLoad ? "${attrs.apiContentLoad}" : null,
			beforeTitleUpdate: attrs.apiBeforeTitleUpdate ? "${attrs.apiBeforeTitleUpdate}" : null,
			onTitleUpdate: attrs.apiOnTitleUpdate ? "${attrs.apiOnTitleUpdate}" : null,
			beforeDestroy: attrs.apiBeforeDestroy ? "${attrs.apiBeforeDestroy}" : null,
			onDestroy: attrs.apiOnDestroy ? "${attrs.apiOnDestroy}" : null,
			beforeFocus: attrs.apiBeforeFocus ? "${attrs.apiBeforeFocus}" : null,
			onFocus: attrs.apiOnFocus ? "${attrs.apiOnFocus}" : null
    ]

    def params = [
            content: content,
            position: position,
            show: show,
            hide: hide,
            style: style,
            api: api
    ]

    tooltipCode += params.findAll {k, v -> v != null}.collect {k, v ->
      if (v instanceof Collection || v instanceof Map) {
        " $k:${UtilsWebComponents.formatColForJS(v)}"
      } else {
        " $k:$v"
      }
    }.join(',')

    tooltipCode += "});"
    out << jq.jquery(null, tooltipCode)
  }
}