<g:set var="releaseNotesURL" value="${message(code:'is.ui.whatsnew.releaseNotesURL', args:['r611'])}"/>
<is:dialog
        resizable="false"
        withTitlebar="false"
        width="650"
        id="dialog-whatsnew"
        buttons="'${message(code:'is.button.close')}': function() { ${remoteFunction(controller:'scrumOS',action:'whatsNew',params:[hide:true])}; jQuery(this).dialog('close'); }"
        draggable="false">
        <div class='box-form box-form-250 box-form-200-legend'>
            <is:fieldset title="is.ui.whatsnew.title" id="member-autocomplete">
                <is:fieldInformation noborder="true">${message(code:'is.ui.whatsnew.description', args:[g.meta(name:"app.version")])}</is:fieldInformation>
                <div class="features-list">
                    <ul>
                        <li>
                            <a href="${releaseNotesURL}" target="_blank"><r:img uri="/themes/is/images/whatsNew/actors.png"/></a>
                            <a href="${releaseNotesURL}" class="scrum-link" target="_blank">Story description template and autocomplete on actors</a>
                        </li>
                        <li>
                            <a href="${releaseNotesURL}" target="_blank"><r:img uri="/themes/is/images/whatsNew/select.png"/></a>
                            <a href="${releaseNotesURL}" class="scrum-link" target="_blank">Better UI and search field on large drop-down lists</a>
                        </li>
                        <li>
                            <a href="${releaseNotesURL}" target="_blank"><r:img uri="/themes/is/images/whatsNew/returnToSandbox.png"/></a>
                            <a href="${releaseNotesURL}" class="scrum-link" target="_blank">Move a story from the backlog back to the sandbox</a>
                        </li>
                    </ul>
                    <span class="more">
                        <g:message code="is.ui.whatsnew.more"/> <a href="${releaseNotesURL}" target="_blank" class="scrum-link">${message(code:"is.ui.whatsnew.releaseNotes", args:[g.meta(name:"app.version")])}</a>
                    </span>
                    <g:set var="now" value="${new Date()}"/>
                    <g:set var="validFrom" value="${new Date('10/12/2013')}"/>
                    <g:set var="validTo" value="${new Date('01/07/2014')}"/>
                    <g:if test="${validFrom.before(now) && validTo.after(now)}">
                        <span class="more wishes">
                            <g:message code="is.ui.holidaySeasonWishes"/>
                        </span>
                    </g:if>
                </div>
            </is:fieldset>
        </div>
</is:dialog>