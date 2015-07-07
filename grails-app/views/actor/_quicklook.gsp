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
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
--}%
<is:dialog width="600"
           resizable="false"
           draggable="false"
           withTitlebar="false"
           buttons="'${message(code: 'is.button.close')}': function() {\$(this).dialog('close'); }"
           focusable="${false}">
<div class="postit-details postit-details-actor quicklook" data-elemid="${actor.id}">
    <div class="colset-2 clearfix">
        <div class="col1 postit-details-information">
            <p>
                <strong><g:message code="is.backlogelement.id"/> :</strong> ${actor.uid}
            </p>

            <p>
                <strong><g:message code="is.actor.name"/> :</strong> ${actor.name.encodeAsHTML()}
            </p>
            <p>
                <strong><g:message
                        code="is.backlogelement.description"/> :</strong> ${actor.description?.encodeAsHTML()?.encodeAsNL2BR()}
            </p>

            <div class="line">
                <strong><g:message code="is.backlogelement.notes"/> :</strong>

                <div class="content rich-content">
                    <is:renderHtml>${actor.notes}</is:renderHtml>
                </div>
            </div>

            <p>
                <strong><g:message code="is.backlogelement.creationDate"/> :</strong>
                <g:formatDate date="${actor.creationDate}" formatName="is.date.format.short.time"
                              timeZone="${actor.backlog.preferences.timezone}"/>
            </p>

            <p>
                <strong><g:message
                        code="is.actor.satisfaction.criteria"/> :</strong> ${actor.satisfactionCriteria?.encodeAsHTML()?.encodeAsNL2BR()}
            </p>

            <p>
                <strong><g:message code="is.actor.it.level"/> :</strong> <g:message code="${expertnessLevelCode}"/>
            </p>

            <p>
                <strong><g:message code="is.actor.use.frequency"/> :</strong> <g:message code="${useFrequencyCode}"/>
            </p>

            <p>
                <strong><g:message code="is.actor.instances"/> :</strong> <g:message code="${instancesCode}"/>
            </p>

            <p>
                <strong><g:message code="is.actor.nb.stories"/> :</strong> ${stories}
            </p>
            <g:if test="${actor.tags}">
                <div class="line last">
                    <strong><g:message code="is.backlogelement.tags"/> :</strong>&nbsp;<g:each var="tag" status="i" in="${actor.tags}"> <a href="#finder?tag=${tag}">${tag}</a>${i < actor.tags.size() - 1 ? ', ' : ''}</g:each>
                </div>
            </g:if>
            <entry:point id="quicklook-actor-left" model="[actor:actor]"/>
        </div>

        <div class="col2">
            <is:postit id="${actor.id}"
                       miniId="${actor.uid}"
                       title="${actor.name}"
                       type="actor"
                       rect="true"
                       controller="actor">
            </is:postit>
            <g:if test="${actor.totalAttachments}">
                <div>
                    <strong>${message(code: 'is.postit.attachment', args: [actor.totalAttachments, actor.totalAttachments > 1 ? 's' : ''])} :</strong>
                    <is:attachedFiles bean="${actor}" width="120" deletable="${false}" controller="actor" params="[product:params.product]" size="20"/>
                </div>
            </g:if>
            <entry:point id="quicklook-actor-right" model="[actor:actor]"/>
        </div>
    </div>
</div>
</is:dialog>
<is:onStream
        on=".postit-details-actor[data-elemid=${actor.id}]"
        events="[[object:'actor',events:['update']]]"
        constraint="actor.id == ${actor.id}"
        callback="\$.icescrum.displayQuicklook(\$('#dialog .postit-actor'));"/>
<is:onStream
        on=".postit-details-actor[data-elemid=${actor.id}]"
        events="[[object:'actor',events:['remove']]]"
        constraint="actor.id == ${actor.id}"
        callback="alert('${message(code:'is.actor.deleted')}'); jQuery('#dialog').dialog('close');"/>
