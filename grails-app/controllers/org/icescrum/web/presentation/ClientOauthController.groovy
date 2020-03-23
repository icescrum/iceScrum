package org.icescrum.web.presentation

import grails.converters.JSON
import org.icescrum.core.error.ControllerErrorHandler
import org.icescrum.core.security.WorkspaceSecurity
import org.icescrum.core.support.ApplicationSupport
import org.springframework.security.access.annotation.Secured

@Secured('permitAll')
class ClientOauthController implements ControllerErrorHandler, WorkspaceSecurity {

    def springSecurityService
    def grailsApplication
    def metaDataService

    def save(long workspace, String workspaceType, String providerId) {
        if (!checkPermission(
                project: 'inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        def oauth = [oauth: params.oauth]
        Class<?> WorkspaceClass = grailsApplication.getDomainClass('org.icescrum.core.domain.' + workspaceType.capitalize()).clazz
        def _workspace = WorkspaceClass.load(workspace)
        metaDataService.addOrUpdateMetadata(_workspace, "oauth-${providerId}", oauth)
        render(status: 200, contentType: 'application/json', text: oauth as JSON)
    }

    def show(long workspace, String workspaceType, String providerId) {
        if (!checkPermission(
                project: 'inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        Class<?> WorkspaceClass = grailsApplication.getDomainClass('org.icescrum.core.domain.' + workspaceType.capitalize()).clazz
        def _workspace = WorkspaceClass.load(workspace)
        def data = metaDataService.getMetadata(_workspace, "oauth-${providerId}", true)
        // Maybe refresh token so refresh if needed
        if (data?.oauth?.expires_on && data?.oauth?.refresh_token) {
            if (new Date().getTime() >= data.oauth.expires_on.toLong()) {
                def result = getToken(providerId, data.oauth.refresh_token, true)
                if (result) {
                    data.oauth.expires_in = result.expires_in
                    data.oauth.access_token = result.access_token
                    data.oauth.refresh_token = result.refresh_token ?: data.oauth.refresh_token
                    data.oauth.expires_on = new Date().getTime() + (result.expires_in * 1000)
                    metaDataService.addOrUpdateMetadata(_workspace, "oauth-${providerId}", data)
                }
            }
        }
        render(status: 200, contentType: 'application/json', text: data as JSON)
    }

    def delete(long workspace, String workspaceType, String providerId) {
        if (!checkPermission(
                project: 'inProject()',
                portfolio: 'businessOwner() or portfolioStakeHolder()'
        )) {
            return
        }
        Class<?> WorkspaceClass = grailsApplication.getDomainClass('org.icescrum.core.domain.' + workspaceType.capitalize()).clazz
        def _workspace = WorkspaceClass.load(workspace)
        def data = metaDataService.addOrUpdateMetadata(_workspace, "oauth-${providerId}", null)
        render(status: 204)
    }

    def token(String providerId) {
        def posted = request.JSON
        def result = getToken(providerId, posted.code ?: params.code, false)
        if (result) {
            result.expires_on = new Date().getTime() + (result.expires_in * 1000)
            render(status: 200, contentType: 'application/json', text: result)
        } else {
            render(status: 400)
        }
    }

    def redirectUri() {
        render(status: 200, text: '')
    }

    private def getToken(String providerId, String code, boolean refresh) {
        def clientOauthData = grailsApplication.config.icescrum.clientsOauth.find { key, values ->
            key == providerId
        }?.value
        if (!clientOauthData) {
            return false
        }
        def method = clientOauthData.method ?: 'POST'
        def grant_type = refresh ? "refresh_token" : "authorization_code";
        def redirect_uri = ApplicationSupport.serverURL() + "/clientOauth/redirectUri"
        def queryString = (refresh ? "refreshToken" : "code") + "=${code}&client_id=${clientOauthData.clientId}&client_secret=${clientOauthData.clientSecret}&grant_type=${grant_type}&redirect_uri=${redirect_uri}"
        def url = "${clientOauthData.tokenUrl}"
        if (clientOauthData.forceQueryParams || method == 'GET') {
            url += "?" + queryString
        }
        def baseUrl = new URL(url)
        def connection = baseUrl.openConnection()
        connection.with {
            doOutput = true
            requestMethod = method ?: 'POST'
            if (!clientOauthData.forceQueryParams || method == 'POST') {
                outputStream.withWriter { writer ->
                    writer << queryString
                }
            }
            if (responseCode == 200) {
                return JSON.parse(content.text)
            } else {
                return false
            }
        }
    }
}
