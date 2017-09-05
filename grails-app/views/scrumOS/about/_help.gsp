<div>
    <g:set var="analytics" value="?utm_source=about&utm_medium=link&utm_campaign=icescrum"/>
    <p>
        <strong><g:message code="is.dialog.about.version.link"/></strong> : <a href="${version.link.toString() + analytics}" target="_blank">${version.link}</a>
    </p>
    <p>
        <strong><g:message code="is.dialog.about.version.pro"/></strong> : <a href="${version.pro.toString() + analytics}" target="_blank">${version.pro}</a>
    </p>
    <p>
        <strong><g:message code="is.dialog.about.version.documentation.link"/></strong> : <a href="${version.documentation.toString() + analytics}" target="_blank">${version.documentation}</a>
    </p>
    <p>
        <strong><g:message code="is.dialog.about.version.documentation.gettingStarted"/></strong> : <a href="${version.gettingStarted.toString() + analytics}" target="_blank">${version.gettingStarted}</a>
    </p>
    <p>
        <strong><g:message code="is.dialog.about.version.forum.link"/></strong> : <a href="${version.forum.toString() + analytics}" target="_blank">${version.forum}</a>
    </p>
    <br/>
    <h4><g:message code="is.dialog.about.version.build.title"/></h4>
    <div class="table-responsive">
        <table class="table table-bordered table-striped">
            <tbody>
            <tr>
                <td><strong><g:message code="is.dialog.about.version.appVersion"/></strong></td>
                <td>${versionNumber.contains('Cloud') ? versionNumber : versionNumber + ' Standalone'}</td>
            </tr>
            <g:if test="${request.authenticated}">
                <tr>
                    <td><strong><g:message code="is.dialog.about.appID"/></strong></td>
                    <td><is:appId/></td>
                </tr>
            </g:if>
            <g:if test="${request.admin}">
                <tr>
                    <td><g:message code="is.dialog.about.version.configLocation"/></td>
                    <td>${configLocation}</td>
                </tr>
                <g:if test="${g.meta(name: 'build.date')}">
                    <tr>
                        <td><g:message code="is.dialog.about.version.buildDate"/></td>
                        <td><g:meta name="build.date"/></td>
                    </tr>
                </g:if>
                <g:if test="${g.meta(name: 'environment.BUILD_NUMBER')}">
                    <tr>
                        <td><g:message code="is.dialog.about.version.buildNumber"/></td>
                        <td>#<g:meta name="environment.BUILD_NUMBER"/></td>
                    </tr>
                </g:if>
                <g:if test="${g.meta(name: 'environment.BUILD_ID')}">
                    <tr>
                        <td><g:message code="is.dialog.about.version.buildID"/></td>
                        <td><g:meta name="environment.BUILD_ID"/></td>
                    </tr>
                </g:if>
                <g:if test="${g.meta(name: 'environment.BUILD_TAG')}">
                    <tr>
                        <td><g:message code="is.dialog.about.version.buildTag"/></td>
                        <td><g:meta name="environment.BUILD_TAG"/></td>
                    </tr>
                </g:if>
                <g:if test="${System.getProperty('grails.env')}">
                    <tr>
                        <td><g:message code="is.dialog.about.version.env"/></td>
                        <td>${System.getProperty('grails.env')}</td>
                    </tr>
                </g:if>
                <tr>
                    <td><g:message code="is.dialog.about.version.grailsVersion"/></td>
                    <td><g:meta name="app.grails.version"/></td>
                </tr>
                <tr>
                    <td><g:message code="is.dialog.about.version.javaVersion"/></td>
                    <td>${System.getProperty('java.version')}</td>
                </tr>
                <tr>
                    <td><g:message code="is.dialog.about.version.serverVersion"/></td>
                    <td>${server}</td>
                </tr>
            </g:if>
            </tbody>
        </table>
    </div>
</div>