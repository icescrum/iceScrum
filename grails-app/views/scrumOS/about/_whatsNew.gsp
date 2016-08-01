<%@ page import="org.icescrum.core.support.ApplicationSupport;" %>
<g:set var="releaseNotesURL" value="${message(code:'is.ui.whatsnew.releaseNotesURL', args:['r614'])}"/>
<is:dialog
        resizable="false"
        withTitlebar="false"
        width="700"
        id="dialog-whatsnew"
        buttons="'${message(code:'is.button.close')}': function() { ${remoteFunction(controller:'scrumOS',action:'whatsNew',params:[hide:true])}; jQuery(this).dialog('close'); }"
        draggable="false">
        <div class='box-form box-form-250 box-form-200-legend'>
            <is:fieldset title="You are now using iceScrum R6#14.11!" id="member-autocomplete">
                <is:fieldInformation noborder="true">This minor version brings some improvements and bug fixes. It's one of the last before iceScrum 7. Try the beta version on our website!</is:fieldInformation>
                <div class="features-list">
                    <ul>
                        <li>
                            <a href="https://www.icescrum.com/documentation/git-svn/#scm-configuration_4" target="_blank"><r:img uri="/themes/is/images/whatsNew/gitlab.png" width="160px"/></a>
                            <a href="https://www.icescrum.com/documentation/git-svn/#scm-configuration_4" class="scrum-link" target="_blank">GitLab integration</a>
                        </li>
                        <li>
                            <a href="${releaseNotesURL}" target="_blank"><r:img uri="/themes/is/images/whatsNew/oracle.png" width="160px"/></a>
                            <a href="${releaseNotesURL}" class="scrum-link" target="_blank">Oracle support</a>
                        </li>
                        <li>
                            <a href="https://www.icescrum.com" target="_blank"><r:img uri="/themes/is/images/whatsNew/site.png" width="160px"/></a>
                            <a href="https://www.icescrum.com" class="scrum-link" target="_blank">iceScrum 7 Beta</a>
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