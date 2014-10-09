package org.icescrum.web.presentation.app

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User

class TeamController {

    def springSecurityService

    @Secured('isAuthenticated()')
    def search() {
        def canBecreated = true
        def teams = Team.findAllByOwnerAndName(((User)springSecurityService.currentUser).username, (String)params.value, [:]).collect{
            def teamName = it.name.split("team")
            it.name = teamName.size() > 1 && (teamName[1].trim().startsWith('201')) ? teamName[0] : it.name
            canBecreated = canBecreated && teamName == params.value ? false : canBecreated
            return it
        }
        if (canBecreated){
            teams.add(0, [name:params.value, members:[], scrumMasters:[]])
        }
        withFormat{
            html {
                render(status:200, text:teams as JSON, contentType:'application/json')
            }
            json { renderRESTJSON(text:teams) }
            xml  { renderRESTXML(text:teams) }
        }
    }
}
