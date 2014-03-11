<%@ page import="org.icescrum.core.support.ApplicationSupport;" %>
<g:set var="releaseNotesURL" value="${message(code:'is.ui.whatsnew.releaseNotesURL', args:[ApplicationSupport.getNormalisedVersion()])}"/>
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
                            <a href="${releaseNotesURL}" target="_blank"><r:img uri="/themes/is/images/whatsNew/customEffort.png"/></a>
                            <a href="${releaseNotesURL}" class="scrum-link" target="_blank">Custom effort on stories</a>
                        </li>
                        <li>
                            <a href="${releaseNotesURL}" target="_blank"><r:img uri="/themes/is/images/whatsNew/bugzillaServer.png"/></a>
                            <a href="${releaseNotesURL}" class="scrum-link" target="_blank">Bugzilla integration</a>
                        </li>
                        <li>
                            <a href="${releaseNotesURL}" target="_blank"><r:img uri="/themes/is/images/whatsNew/customTags.png"/></a>
                            <a href="${releaseNotesURL}" class="scrum-link" target="_blank">Imported stories custom tags</a>
                        </li>
                    </ul>
                    <span class="more">
                        <g:message code="is.ui.whatsnew.more"/> <a href="${releaseNotesURL}" target="_blank" class="scrum-link">${message(code:"is.ui.whatsnew.releaseNotes", args:[g.meta(name:"app.version")])}</a>
                    </span>
                    <g:set var="now" value="${new Date()}"/>
                    <g:set var="validFrom" value="${new Date('22/12/2013')}"/>
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