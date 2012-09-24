/*
 * Copyright (c) 2010 iceScrum Technologies.
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

Timeline.IceScrumEventPainter = function(params) {
    this._params = params;
    this._onSelectListeners = [];
    this._eventPaintListeners = [];
    
    this._filterMatcher = null;
    this._highlightMatcher = null;
    this._frc = null;
    
    this._eventIdToElmt = {};
};

Timeline.IceScrumEventPainter.prototype.initialize = function(band, timeline) {
    this._band = band;
    this._timeline = timeline;
    
    this._backLayer = null;
    this._eventLayer = null;
    this._lineLayer = null;
    this._highlightLayer = null;
    
    this._eventIdToElmt = null;
};

Timeline.IceScrumEventPainter.prototype.getType = function() {
    return 'icescrum';
};

Timeline.IceScrumEventPainter.prototype.addOnSelectListener = function(listener) {
    this._onSelectListeners.push(listener);
};

Timeline.IceScrumEventPainter.prototype.removeOnSelectListener = function(listener) {
    for (var i = 0; i < this._onSelectListeners.length; i++) {
        if (this._onSelectListeners[i] == listener) {
            this._onSelectListeners.splice(i, 1);
            break;
        }
    }
};

Timeline.IceScrumEventPainter.prototype.addEventPaintListener = function(listener) {
    this._eventPaintListeners.push(listener);
};

Timeline.IceScrumEventPainter.prototype.removeEventPaintListener = function(listener) {
    for (var i = 0; i < this._eventPaintListeners.length; i++) {
        if (this._eventPaintListeners[i] == listener) {
            this._eventPaintListeners.splice(i, 1);
            break;
        }
    }
};

Timeline.IceScrumEventPainter.prototype.getFilterMatcher = function() {
    return this._filterMatcher;
};

Timeline.IceScrumEventPainter.prototype.setFilterMatcher = function(filterMatcher) {
    this._filterMatcher = filterMatcher;
};

Timeline.IceScrumEventPainter.prototype.getHighlightMatcher = function() {
    return this._highlightMatcher;
};

Timeline.IceScrumEventPainter.prototype.setHighlightMatcher = function(highlightMatcher) {
    this._highlightMatcher = highlightMatcher;
};

Timeline.IceScrumEventPainter.prototype.paint = function() {
    // Paints the events for a given section of the band--what is
    // visible on screen and some extra.
    var eventSource = this._band.getEventSource();
    if (eventSource == null) {
        return;
    }
    
    this._eventIdToElmt = {};
    this._fireEventPaintListeners('paintStarting', null, null);
    this._prepareForPainting();
    
    var eventTheme = this._params.theme.event;
    var trackHeight = Math.max(eventTheme.track.height, eventTheme.tape.height + 
                        this._frc.getLineHeight());
    var metrics = {
           trackOffset: eventTheme.track.offset,
           trackHeight: trackHeight,
              trackGap: eventTheme.track.gap,
        trackIncrement: trackHeight + eventTheme.track.gap,
                  icon: eventTheme.instant.icon,
             iconWidth: eventTheme.instant.iconWidth,
            iconHeight: eventTheme.instant.iconHeight,
            labelWidth: eventTheme.label.width,
          maxLabelChar: eventTheme.label.maxLabelChar,
   impreciseIconMargin: eventTheme.instant.impreciseIconMargin
    }
    
    var minDate = this._band.getMinDate();
    var maxDate = this._band.getMaxDate();
    
    var filterMatcher = (this._filterMatcher != null) ? 
        this._filterMatcher :
        function(evt) { return true; };
    var highlightMatcher = (this._highlightMatcher != null) ? 
        this._highlightMatcher :
        function(evt) { return -1; };
    
    var iterator = eventSource.getEventReverseIterator(minDate, maxDate);
    while (iterator.hasNext()) {
        var evt = iterator.next();
        if (filterMatcher(evt)) {
            this.paintEvent(evt, metrics, this._params.theme, highlightMatcher(evt));
        }
    }
    
    this._highlightLayer.style.display = "block";
    this._lineLayer.style.display = "block";
    this._eventLayer.style.display = "block";
    // update the band object for max number of tracks in this section of the ether
    this._band.updateEventTrackInfo(this._tracks.length, metrics.trackIncrement); 
    this._fireEventPaintListeners('paintEnded', null, null);
};

Timeline.IceScrumEventPainter.prototype.softPaint = function() {
};

Timeline.IceScrumEventPainter.prototype._prepareForPainting = function() {
    // Remove everything previously painted: highlight, line and event layers.
    // Prepare blank layers for painting. 
    var band = this._band;
        
    if (this._backLayer == null) {
        this._backLayer = this._band.createLayerDiv(0, "timeline-band-events");
        this._backLayer.style.visibility = "hidden";
        
        var eventLabelPrototype = document.createElement("span");
        eventLabelPrototype.className = "timeline-event-label";
        this._backLayer.appendChild(eventLabelPrototype);
        this._frc = SimileAjax.Graphics.getFontRenderingContext(eventLabelPrototype);
    }
    this._frc.update();
    this._tracks = [];
    
    if (this._highlightLayer != null) {
        band.removeLayerDiv(this._highlightLayer);
    }
    this._highlightLayer = band.createLayerDiv(105, "timeline-band-highlights");
    this._highlightLayer.style.display = "none";
    
    if (this._lineLayer != null) {
        band.removeLayerDiv(this._lineLayer);
    }
    this._lineLayer = band.createLayerDiv(110, "timeline-band-lines");
    this._lineLayer.style.display = "none";
    
    if (this._eventLayer != null) {
        band.removeLayerDiv(this._eventLayer);
    }
    this._eventLayer = band.createLayerDiv(115, "timeline-band-events");
    this._eventLayer.style.display = "none";
};

Timeline.IceScrumEventPainter.prototype.paintEvent = function(evt, metrics, theme, highlightIndex) {
    if (evt.isInstant()) {
        this.paintInstantEvent(evt, metrics, theme, highlightIndex);
    } else {
        this.paintDurationEvent(evt, metrics, theme, highlightIndex);
    }
};
    
Timeline.IceScrumEventPainter.prototype.paintInstantEvent = function(evt, metrics, theme, highlightIndex) {
    if (evt.isImprecise()) {
        this.paintImpreciseInstantEvent(evt, metrics, theme, highlightIndex);
    } else {
        this.paintPreciseInstantEvent(evt, metrics, theme, highlightIndex);
    }
}

Timeline.IceScrumEventPainter.prototype.paintDurationEvent = function(evt, metrics, theme, highlightIndex) {
    if (evt.isImprecise()) {
        this.paintImpreciseDurationEvent(evt, metrics, theme, highlightIndex);
    } else {
        this.paintPreciseDurationEvent(evt, metrics, theme, highlightIndex);
    }
}
    
Timeline.IceScrumEventPainter.prototype.paintPreciseInstantEvent = function(evt, metrics, theme, highlightIndex) {
    var doc = this._timeline.getDocument();
    var text = evt.getText();
    
    var startDate = evt.getStart();
    var startPixel = Math.round(this._band.dateToPixelOffset(startDate));
    var iconRightEdge = Math.round(startPixel + metrics.iconWidth / 2);
    var iconLeftEdge = Math.round(startPixel - metrics.iconWidth / 2);

    var labelDivClassName = this._getLabelDivClassName(evt);
    var labelSize = this._frc.computeSize(text, labelDivClassName);
    var labelLeft = iconRightEdge + theme.event.label.offsetFromLine;
    var labelRight = labelLeft + labelSize.width;
    
    var rightEdge = labelRight;
    var track = this._findFreeTrack(evt, rightEdge);
    
    var labelTop = Math.round(
        metrics.trackOffset + track * metrics.trackIncrement + 
        metrics.trackHeight / 2 - labelSize.height / 2);
        
    var iconElmtData = this._paintEventIcon(evt, track, iconLeftEdge, metrics, theme, 0);
    var labelElmtData = this._paintEventLabel(evt, text, labelLeft, labelTop, labelSize.width,
        labelSize.height, theme, labelDivClassName, highlightIndex);
    var els = [iconElmtData.elmt, labelElmtData.elmt];

    var self = this;
    var clickHandler = function(elmt, domEvt, target) {
        return self._onClickInstantEvent(iconElmtData.elmt, domEvt, evt);
    };
    SimileAjax.DOM.registerEvent(iconElmtData.elmt, "click", clickHandler);
    SimileAjax.DOM.registerEvent(labelElmtData.elmt, "click", clickHandler);
    
    var hDiv = this._createHighlightDiv(highlightIndex, iconElmtData, theme, evt);
    if (hDiv != null) {els.push(hDiv);}
    this._fireEventPaintListeners('paintedEvent', evt, els);

    
    this._eventIdToElmt[evt.getID()] = iconElmtData.elmt;
    this._tracks[track] = iconLeftEdge;
};

Timeline.IceScrumEventPainter.prototype.paintImpreciseInstantEvent = function(evt, metrics, theme, highlightIndex) {
    var doc = this._timeline.getDocument();
    var text = evt.getText();
    
    var startDate = evt.getStart();
    var endDate = evt.getEnd();
    var startPixel = Math.round(this._band.dateToPixelOffset(startDate));
    var endPixel = Math.round(this._band.dateToPixelOffset(endDate));
    
    var iconRightEdge = Math.round(startPixel + metrics.iconWidth / 2);
    var iconLeftEdge = Math.round(startPixel - metrics.iconWidth / 2);
    
    var labelDivClassName = this._getLabelDivClassName(evt);
    var labelSize = this._frc.computeSize(text, labelDivClassName);
    var labelLeft = iconRightEdge + theme.event.label.offsetFromLine;
    var labelRight = labelLeft + labelSize.width;
    
    var rightEdge = Math.max(labelRight, endPixel);
    var track = this._findFreeTrack(evt, rightEdge);
    var tapeHeight = theme.event.tape.height;
    var labelTop = Math.round(
        metrics.trackOffset + track * metrics.trackIncrement + tapeHeight);

    var iconElmtData = this._paintEventIcon(evt, track, iconLeftEdge, metrics, theme, tapeHeight);
    var labelElmtData = this._paintEventLabel(evt, text, labelLeft, labelTop, labelSize.width,
                        labelSize.height, theme, labelDivClassName, highlightIndex);

    var color = evt.getColor();
    color = color != null ? color : theme.event.instant.impreciseColor;

    var tapeElmtData = this._paintEventTape(evt, track, startPixel, endPixel, 
        color, theme.event.instant.impreciseOpacity, metrics, theme, 0);
    var els = [iconElmtData.elmt, labelElmtData.elmt, tapeElmtData.elmt];    
    
    var self = this;
    var clickHandler = function(elmt, domEvt, target) {
        return self._onClickInstantEvent(iconElmtData.elmt, domEvt, evt);
    };
    SimileAjax.DOM.registerEvent(iconElmtData.elmt, "click", clickHandler);
    SimileAjax.DOM.registerEvent(tapeElmtData.elmt, "click", clickHandler);
    SimileAjax.DOM.registerEvent(labelElmtData.elmt, "click", clickHandler);
    
    var hDiv = this._createHighlightDiv(highlightIndex, iconElmtData, theme, evt);
    if (hDiv != null) {els.push(hDiv);}
    this._fireEventPaintListeners('paintedEvent', evt, els);

    this._eventIdToElmt[evt.getID()] = iconElmtData.elmt;
    this._tracks[track] = iconLeftEdge;
};

Timeline.IceScrumEventPainter.prototype.paintPreciseDurationEvent = function(evt, metrics, theme, highlightIndex) {
    var doc = this._timeline.getDocument();
    var text = evt.getText();
    
    var startDate = evt.getStart();
    var endDate = evt.getEnd();
    var startPixel = Math.round(this._band.dateToPixelOffset(startDate));
    var endPixel = Math.round(this._band.dateToPixelOffset(endDate));
    
    var labelDivClassName = this._getLabelDivClassName(evt);
    var labelSize = this._frc.computeSize(text, labelDivClassName);
    var labelLeft = startPixel;
    var labelRight = labelLeft + labelSize.width;
    
    var rightEdge = Math.max(labelRight, endPixel);
    var track = this._findFreeTrack(evt, rightEdge);
    var labelTop = Math.round(
        metrics.trackOffset + track * metrics.trackIncrement + theme.event.tape.height);
    
    var color = evt.getColor();
    color = color != null ? color : theme.event.duration.color;
    
    var tapeElmtData = this._paintEventTape(evt, track, startPixel, endPixel, color, 100, metrics, theme, 0);
    var labelElmtData = this._paintEventLabel(evt, text, labelLeft, labelTop, labelSize.width,
      labelSize.height, theme, labelDivClassName, highlightIndex);
    var els = [tapeElmtData.elmt, labelElmtData.elmt];
    
    var self = this;
    var clickHandler = function(elmt, domEvt, target) {
        return self._onClickDurationEvent(tapeElmtData.elmt, domEvt, evt);
    };
    SimileAjax.DOM.registerEvent(tapeElmtData.elmt, "click", clickHandler);
    SimileAjax.DOM.registerEvent(labelElmtData.elmt, "click", clickHandler);
    
    var hDiv = this._createHighlightDiv(highlightIndex, tapeElmtData, theme, evt);
    if (hDiv != null) {els.push(hDiv);}
    this._fireEventPaintListeners('paintedEvent', evt, els);
    
    this._eventIdToElmt[evt.getID()] = tapeElmtData.elmt;
    this._tracks[track] = startPixel;
};

Timeline.IceScrumEventPainter.prototype.paintImpreciseDurationEvent = function(evt, metrics, theme, highlightIndex) {
    var doc = this._timeline.getDocument();
    var text = evt.getText();

    var startDate = evt.getStart();
    var latestStartDate = evt.getLatestStart();
    var endDate = evt.getEnd();
    var earliestEndDate = evt.getEarliestEnd();
    
    var startPixel = Math.round(this._band.dateToPixelOffset(startDate));
    var latestStartPixel = Math.round(this._band.dateToPixelOffset(latestStartDate));
    var endPixel = Math.round(this._band.dateToPixelOffset(endDate));
    var earliestEndPixel = Math.round(this._band.dateToPixelOffset(earliestEndDate));
    
    var labelDivClassName = this._getLabelDivClassName(evt);
    var labelSize = this._frc.computeSize(text, labelDivClassName);
    var labelLeft = latestStartPixel;
    var labelRight = labelLeft + labelSize.width;
    
    var rightEdge = Math.max(labelRight, endPixel);
    var track = this._findFreeTrack(evt, rightEdge);
    var labelTop = Math.round(
        metrics.trackOffset + track * metrics.trackIncrement + theme.event.tape.height);
    
    var color = evt.getColor();
    color = color != null ? color : theme.event.duration.color;
    
    // Imprecise events can have two event tapes
    // The imprecise dates tape, uses opacity to be dimmer than precise dates
    var impreciseTapeElmtData = this._paintEventTape(evt, track, startPixel, endPixel, 
        theme.event.duration.impreciseColor,
        theme.event.duration.impreciseOpacity, metrics, theme, 0);
    // The precise dates tape, regular (100%) opacity
    var tapeElmtData = this._paintEventTape(evt, track, latestStartPixel,
        earliestEndPixel, color, 100, metrics, theme, 1);
    
    var labelElmtData = this._paintEventLabel(evt, text, labelLeft, labelTop,
        labelSize.width, labelSize.height, theme, labelDivClassName, highlightIndex);
    var els = [impreciseTapeElmtData.elmt, tapeElmtData.elmt, labelElmtData.elmt];
    
    var self = this;
    var clickHandler = function(elmt, domEvt, target) {
        return self._onClickDurationEvent(tapeElmtData.elmt, domEvt, evt);
    };
    SimileAjax.DOM.registerEvent(tapeElmtData.elmt, "click", clickHandler);
    SimileAjax.DOM.registerEvent(labelElmtData.elmt, "click", clickHandler);
    
    var hDiv = this._createHighlightDiv(highlightIndex, tapeElmtData, theme, evt);
    if (hDiv != null) {els.push(hDiv);}
    this._fireEventPaintListeners('paintedEvent', evt, els);
    
    this._eventIdToElmt[evt.getID()] = tapeElmtData.elmt;
    this._tracks[track] = startPixel;
};

Timeline.IceScrumEventPainter.prototype._encodeEventElID = function(elType, evt) {
    return Timeline.EventUtils.encodeEventElID(this._timeline, this._band, elType, evt);
};

Timeline.IceScrumEventPainter.prototype._findFreeTrack = function(event, rightEdge) {
    var trackAttribute = event.getTrackNum();
    if (trackAttribute != null) {
        return trackAttribute; // early return since event includes track number
    }
    
    // normal case: find an open track
    for (var i = 0; i < this._tracks.length; i++) {
        var t = this._tracks[i];
        if (t > rightEdge) {
            break;
        }
    }
    return i;
};

Timeline.IceScrumEventPainter.prototype._paintEventIcon = function(evt, iconTrack, left, metrics, theme, tapeHeight) {
    // If no tape, then paint the icon in the middle of the track.
    // If there is a tape, paint the icon below the tape + impreciseIconMargin
    var icon = evt.getIcon();
    icon = icon != null ? icon : metrics.icon;

    var top; // top of the icon
    if (tapeHeight > 0) {
        top = metrics.trackOffset + iconTrack * metrics.trackIncrement + 
              tapeHeight + metrics.impreciseIconMargin;
    } else {
        var middle = metrics.trackOffset + iconTrack * metrics.trackIncrement +
                     metrics.trackHeight / 2;
        top = Math.round(middle - metrics.iconHeight / 2);
    }
    var img = SimileAjax.Graphics.createTranslucentImage(icon);
    var iconDiv = this._timeline.getDocument().createElement("div");
    iconDiv.className = this._getElClassName('timeline-event-icon', evt, 'icon');
    iconDiv.id = this._encodeEventElID('icon', evt);
    iconDiv.style.left = left + "px";
    iconDiv.style.top = top + "px";
    iconDiv.appendChild(img);

    if(evt._title != null)
        iconDiv.title = evt._title;

    this._eventLayer.appendChild(iconDiv);

    var self = this;
    var onmouseover = function(elmt, domEvt, target) {
        if (evt._instant)
          return self._onClickInstantEvent(iconDiv, domEvt, evt, false);
        else
          return self._onClickDurationEvent(iconDiv, domEvt, evt, false);
    };
    SimileAjax.DOM.registerEvent(iconDiv, "mouseover",onmouseover);
    
    return {
        left:   left,
        top:    top,
        width:  metrics.iconWidth,
        height: metrics.iconHeight,
        elmt:   iconDiv
    };
};

Timeline.IceScrumEventPainter.prototype._paintEventLabel = function(evt, text, left, top, width,
    height, theme, labelDivClassName, highlightIndex) {
    var doc = this._timeline.getDocument();
    
    var labelDiv = doc.createElement("div");
    labelDiv.className = labelDivClassName;
    labelDiv.id = this._encodeEventElID('label', evt);
    labelDiv.style.left = left + "px";
    labelDiv.style.width = width + "px";
    labelDiv.style.top = top + "px";
    labelDiv.innerHTML = text;

    if(evt._title != null)
        labelDiv.title = evt._title;    

    var color = evt.getTextColor();
    if (color == null) {
        color = evt.getColor();
    }
    if (color != null) {
        labelDiv.style.color = color;
    }
    if (theme.event.highlightLabelBackground && highlightIndex >= 0) {
        labelDiv.style.background = this._getHighlightColor(highlightIndex, theme);
    }
    
    this._eventLayer.appendChild(labelDiv);

    var self = this;
    var onmouseover = function(elmt, domEvt, target) {
        if (evt._instant)
          return self._onClickInstantEvent(labelDiv, domEvt, evt);
        else
          return self._onClickDurationEvent(labelDiv, domEvt, evt);
    };
    SimileAjax.DOM.registerEvent(labelDiv, "mouseover",onmouseover);
    
    return {
        left:   left,
        top:    top,
        width:  width,
        height: height,
        elmt:   labelDiv
    };
};

Timeline.IceScrumEventPainter.prototype._paintEventTape = function(
    evt, iconTrack, startPixel, endPixel, color, opacity, metrics, theme, tape_index) {
    
    var tapeWidth = endPixel - startPixel;
    var tapeHeight = theme.event.tape.height;
    var top = metrics.trackOffset + iconTrack * metrics.trackIncrement;
    
    var tapeDiv = this._timeline.getDocument().createElement("div");
    tapeDiv.className = this._getElClassName('timeline-event-tape', evt, 'tape');
    tapeDiv.id = this._encodeEventElID('tape' + tape_index, evt);
    tapeDiv.style.left = startPixel + "px";
    tapeDiv.style.width = tapeWidth + "px";
    tapeDiv.style.height = tapeHeight + "px";
    tapeDiv.style.top = top + "px";

    if(evt._title != null)
        tapeDiv.title = evt._title;   
   
    if(color != null) {
        tapeDiv.style.backgroundColor = color;
    }
    
    var backgroundImage = evt.getTapeImage();
    var backgroundRepeat = evt.getTapeRepeat();
    backgroundRepeat = backgroundRepeat != null ? backgroundRepeat : 'repeat';
    if(backgroundImage != null) {
      tapeDiv.style.backgroundImage = "url(" + backgroundImage + ")";
      tapeDiv.style.backgroundRepeat = backgroundRepeat;
    } 	
    
    SimileAjax.Graphics.setOpacity(tapeDiv, opacity);
        
    this._eventLayer.appendChild(tapeDiv);

    var self = this;
    var onmouseover = function(elmt, domEvt, target) {
        if (evt._instant)
          return self._onClickInstantEvent(tapeDiv, domEvt, evt);
        else
          return self._onClickDurationEvent(tapeDiv, domEvt, evt);
    };
    SimileAjax.DOM.registerEvent(tapeDiv, "mouseover",onmouseover);

    return {
        left:   startPixel,
        top:    top,
        width:  tapeWidth,
        height: tapeHeight,
        elmt:   tapeDiv
    };
}

Timeline.IceScrumEventPainter.prototype._getLabelDivClassName = function(evt) {
    return this._getElClassName('timeline-event-label', evt, 'label');
};

Timeline.IceScrumEventPainter.prototype._getElClassName = function(elClassName, evt, prefix) {
    // Prefix and '_' is added to the event's classname. Set to null for no prefix
    var evt_classname = evt.getClassName(),
        pieces = [];

    if (evt_classname) {
      if (prefix) {pieces.push(prefix + '-' + evt_classname + ' ');}
      pieces.push(evt_classname + ' ');
    }
    pieces.push(elClassName);
    return(pieces.join(''));
};

Timeline.IceScrumEventPainter.prototype._getHighlightColor = function(highlightIndex, theme) {
    var highlightColors = theme.event.highlightColors;    
    return highlightColors[Math.min(highlightIndex, highlightColors.length - 1)];
};

Timeline.IceScrumEventPainter.prototype._createHighlightDiv = function(highlightIndex, dimensions, theme, evt) {
    var div = null;
    if (highlightIndex >= 0) {
        var doc = this._timeline.getDocument();        
        var color = this._getHighlightColor(highlightIndex, theme);
        
        div = doc.createElement("div");
        div.className = this._getElClassName('timeline-event-highlight', evt, 'highlight');
        div.id = this._encodeEventElID('highlight0', evt); // in future will have other
                                                           // highlight divs for tapes + icons
        div.style.position = "absolute";
        div.style.overflow = "hidden";
        div.style.left =    (dimensions.left - 2) + "px";
        div.style.width =   (dimensions.width + 4) + "px";
        div.style.top =     (dimensions.top - 2) + "px";
        div.style.height =  (dimensions.height + 4) + "px";
        div.style.background = color;
        
        this._highlightLayer.appendChild(div);
    }
    return div;
};

Timeline.IceScrumEventPainter.prototype._onClickInstantEvent = function(icon, domEvt, evt) {
    var c = SimileAjax.DOM.getPageCoordinates(icon);
    this._showBubble(
        c.left + Math.ceil(icon.offsetWidth / 2), 
        c.top + Math.ceil(icon.offsetHeight / 2),
        evt
    );
    this._fireOnSelect(evt.getID());
    
    domEvt.cancelBubble = true;
    SimileAjax.DOM.cancelEvent(domEvt);
    return false;
};

Timeline.IceScrumEventPainter.prototype._onClickDurationEvent = function(target, domEvt, evt) {

    if (domEvt.type == "click"){
      domEvt.cancelBubble = true;
      SimileAjax.DOM.cancelEvent(domEvt);
      if(evt.getProperty('url')){
          document.location = evt.getProperty('url');
      }else if(evt.getProperty('window')){
          $.icescrum.openWindow(evt.getProperty('window'));
      }
      return false;
    }

    if ("pageX" in domEvt) {
        var x = domEvt.pageX;
        var y = domEvt.pageY;
    } else {
        var c = SimileAjax.DOM.getPageCoordinates(target);
        var x = domEvt.offsetX + c.left;
        var y = domEvt.offsetY + c.top;
    }
    this._showBubble(x, y, evt);
    this._fireOnSelect(evt.getID());
    
    domEvt.cancelBubble = true;
    SimileAjax.DOM.cancelEvent(domEvt);
    return false;
};

Timeline.IceScrumEventPainter.prototype.showBubble = function(evt) {
    var elmt = this._eventIdToElmt[evt.getID()];
    if (elmt) {
        var c = SimileAjax.DOM.getPageCoordinates(elmt);
        this._showBubble(c.left + elmt.offsetWidth / 2, c.top + elmt.offsetHeight / 2, evt);
    }
};

Timeline.IceScrumEventPainter.prototype._showBubble = function(x, y, evt) {
    var elmt = $(this._eventIdToElmt[evt.getID()]);
    if (!elmt.data('tooltip')){
        var tooltip = $("<div/>").addClass('tooltip').html(evt.getProperty('tooltipContent'));
        var tooltipTitle = $("<span/>").addClass('tooltip-title').html(evt.getProperty('tooltipTitle'));
        tooltipTitle.prependTo(tooltip);
        tooltip.insertAfter(elmt);
        elmt.data('tooltip-created','true');
        elmt.tipTip({delay:200, activation:"hover", delayHover:500, defaultPosition:"right", content:tooltip.html(), edgeOffset:-20});
        elmt.data('tooltip', true);
        var timeoutOnCreate = setTimeout(function(){ elmt.tipTip('show'); }, 500);
        elmt.mouseleave(function(){ clearTimeout(timeoutOnCreate); elmt.tipTip('hide'); });
    }
};

Timeline.IceScrumEventPainter.prototype._fireOnSelect = function(eventID) {
    for (var i = 0; i < this._onSelectListeners.length; i++) {
        this._onSelectListeners[i](eventID);
    }
};

Timeline.IceScrumEventPainter.prototype._fireEventPaintListeners = function(op, evt, els) {
    for (var i = 0; i < this._eventPaintListeners.length; i++) {
        this._eventPaintListeners[i](this._band, op, evt, els);
    }
};