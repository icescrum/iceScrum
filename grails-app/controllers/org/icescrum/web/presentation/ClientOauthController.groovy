package org.icescrum.web.presentation

import grails.converters.JSON
import org.codehaus.groovy.runtime.ProcessGroovyMethods
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
                def result = getToken(providerId, data.oauth.refresh_token, data.oauth.baseUrl ?: null, data.oauth.clientId ?: null, data.oauth.clientSecret ?: null, true)
                if (result.status == 200) {
                    data.oauth.expires_in = result.content.expires_in
                    data.oauth.access_token = result.content.access_token
                    data.oauth.refresh_token = result.content.refresh_token ?: data.oauth.refresh_token
                    data.oauth.expires_on = new Date().getTime() + (result.content.expires_in * 1000)
                    metaDataService.addOrUpdateMetadata(_workspace, "oauth-${providerId}", data)
                    render(status: 200, contentType: 'application/json', text: result.content)
                } else {
                    render(status: result.status, contentType: 'application/json', text: [text: result.content] as JSON)
                }
                return
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
        def result = getToken(providerId, posted.code, posted.baseTokenUrl ?: null, posted.clientId ?: null, posted.clientSecret ?: null, false)
        if (result.status == 200) {
            result.content.expires_on = new Date().getTime() + (result.content.expires_in * 1000)
            render(status: 200, contentType: 'application/json', text: result.content)
        } else {
            render(status: result.status, contentType: 'application/json', text: [text: result.content] as JSON)
        }
    }

    def redirectUri() {
        render(status: 200, text: '')
    }

    private def getToken(String providerId, String code, String baseTokenUrl, String clientId, String clientSecret, boolean refresh) {
        def clientOauthData = grailsApplication.config.icescrum.clientsOauth.find { key, values ->
            key == providerId
        }?.value
        if (!clientOauthData) {
            return false
        }
        def oauthTokenAuth = clientOauthData.oauthTokenAuth ?: 'params'
        def method = clientOauthData.method ?: 'POST'
        def grant_type = refresh ? 'refresh_token' : 'authorization_code'
        def redirect_uri = ApplicationSupport.serverURL() + "/clientOauth/redirectUri"
        def queryString = (refresh ? 'refresh_token' : 'code') + "=${code}&grant_type=${grant_type}"
        if ((clientSecret || clientOauthData.clientSecret) && oauthTokenAuth != "basic") {
            queryString += "&client_secret=${clientSecret ?: clientOauthData.clientSecret}"
        }
        if ((clientId || clientOauthData.clientId) && oauthTokenAuth != "basic") {
            queryString += "&client_id=${clientId ?: clientOauthData.clientId}"
        }
        if (!refresh) {
            queryString += "&redirect_uri=${redirect_uri}"
        }
        if (clientOauthData.tokenOptionalQueryString) {
            queryString += clientOauthData.tokenOptionalQueryString
        }
        def url = "${baseTokenUrl ?: ''}${clientOauthData.tokenUrl}"
        if (clientOauthData.forceQueryParams || method == 'GET') {
            url += "?" + queryString
        }
        def baseUrl = new URL(url)
        def connection = baseUrl.openConnection()
        connection.with {
            doOutput = true
            if (oauthTokenAuth == 'basic') {
                String basicAuth = "Basic " + new String(Base64.encoder.encode("${clientId ?: clientOauthData.clientId}:${clientSecret ?: clientOauthData.clientSecret ?: ''}".bytes))
                setRequestProperty("Authorization", basicAuth)
            } else {
                setRequestProperty("Content-Type", 'application/x-www-form-urlencoded')
            }
            setRequestProperty("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:33.0) Gecko/20100101 Firefox/33.0")
            setRequestProperty("Connection", "keep-alive")
            requestMethod = method ?: 'POST'
            if (!clientOauthData.forceQueryParams || method == 'POST') {
                outputStream.withWriter { writer ->
                    writer << queryString
                }
            }
            if (responseCode != 200) {
                return [status: responseCode, content: errorStream.text]
            } else {
                return [status: responseCode, content: JSON.parse(inputStream.text)]
            }
        }
    }
}
