%{--
  - Copyright (c) 2010 iceScrum Technologies.
  -
  - This file is part of iceScrum.
  -
  - iceScrum is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Affero General Public License as published by
  - the Free Software Foundation, either version 3 of the License.
  -
  - iceScrum is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU General Public License for more details.
  -
  - You should have received a copy of the GNU Affero General Public License
  - along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
  --}%

<is:timeline
        id="release-timeline"
        name="timelineTl"
        container="#window-id-${id}"
        height="100%"
        >
  <is:customBubble
          enable="true"
          container="#window-content-${id}"/>
  
  <is:timelineBand
    action="timeLineList"
    height="80%"
    intervalUnit="MONTH"
    params="[team:params.team]"
    eventPainter="Timeline.IceScrumEventPainter"
    themeOptions="event.track.height = 45,event.tape.height = 40"
    intervalPixels="150">
  </is:timelineBand>

  <is:timelineBand
    action="timeLineList"
    height="20%"
    intervalUnit="MONTH"
    params="[team:params.team]"
    overview="true"
    intervalPixels="90">
      <is:bandOptions showToday="true" syncWith="0" highlight="true" />
  </is:timelineBand>

</is:timeline>
<jq:jquery>
  jQuery("#window-content-${id}").removeClass('window-content-toolbar');
  jQuery("#window-id-${id}").focus();
  <is:renderNotice />
   <icep:notifications
        name="${id}Window"
        reload="[update:'#window-content-'+id,action:'index',params:[team:params.team]]"
        group="${params.team}-${id}"
        listenOn="#window-content-${id}"/>
</jq:jquery>