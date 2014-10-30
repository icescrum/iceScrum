/*
 * Copyright (c) 2014 Kagilum SAS
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

package org.icescrum.web.presentation.app

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.AcceptanceTest
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.User

class AcceptanceTestController {

    def springSecurityService
    def acceptanceTestService

    @Secured('stakeHolder() and !archivedProduct()')
    def index(long id, long product) {
        AcceptanceTest acceptanceTest = AcceptanceTest.withAcceptanceTest(product, id)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: acceptanceTest as JSON }
            json { renderRESTJSON text:acceptanceTest }
            xml  { renderRESTXML text:acceptanceTest }
        }
    }

    @Secured('stakeHolder() and !archivedProduct()')
    def list(long product) {
        def acceptanceTests = params.parentStory ? AcceptanceTest.getAllInStory(product, params.long('parentStory')) : AcceptanceTest.getAllInProduct(product)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: acceptanceTests as JSON }
            json { renderRESTJSON text: acceptanceTests }
            xml  { renderRESTXML text: acceptanceTests }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def save(long product) {
        def acceptanceTestParams = params.acceptanceTest
        if (!acceptanceTestParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
            return
        }
        def story = Story.withStory(product, acceptanceTestParams.parentStory.id.toLong())
        if (story.state >= Story.STATE_DONE) {
            returnError(text: message(code: 'is.acceptanceTest.error.save.storyState'))
            return
        }
        def state = acceptanceTestParams.state?.toInteger()
        def newState
        if (state != null) {
            if (AcceptanceTest.AcceptanceTestState.exists(state)) {
                newState = AcceptanceTest.AcceptanceTestState.byId(state)
                if (newState > AcceptanceTest.AcceptanceTestState.TOCHECK && story.state != Story.STATE_INPROGRESS) {
                    returnError(text: message(code: 'is.acceptanceTest.error.update.state.storyState'))
                    return
                }
            } else {
                returnError(text: message(code: 'is.acceptanceTest.error.state.not.exist'))
                return
            }
        }
        User user = (User) springSecurityService.currentUser
        def acceptanceTest = new AcceptanceTest()
        try {
            AcceptanceTest.withTransaction {
                if (newState) {
                    acceptanceTest.stateEnum = newState
                }
                bindData(acceptanceTest, acceptanceTestParams, [include:['name','description']])
                acceptanceTestService.save(acceptanceTest, story, user)
            }
        } catch (RuntimeException e) {
            returnError(object: acceptanceTest, exception: e)
            return
        }
        withFormat {
            html { render status: 200, contentType: 'application/json', text: acceptanceTest as JSON }
            json { renderRESTJSON status: 201, text:acceptanceTest }
            xml  { renderRESTXML status: 201, text:acceptanceTest }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def update(long id, long product) {
        def acceptanceTestParams = params.acceptanceTest
        if (!acceptanceTestParams) {
            returnError(text: message(code: 'todo.is.ui.no.data'))
            return
        }
        AcceptanceTest acceptanceTest = AcceptanceTest.withAcceptanceTest(product, id)
        def story = acceptanceTest.parentStory
        if (story.state >= Story.STATE_DONE) {
            returnError(text: message(code: 'is.acceptanceTest.error.update.storyState'))
            return
        }
        def state = acceptanceTestParams.state?.toInteger()
        def newState
        if (state != null) {
            if (AcceptanceTest.AcceptanceTestState.exists(state)) {
                newState = AcceptanceTest.AcceptanceTestState.byId(state)
                if (newState > AcceptanceTest.AcceptanceTestState.TOCHECK && story.state != Story.STATE_INPROGRESS) {
                    returnError(text: message(code: 'is.acceptanceTest.error.update.state.storyState'))
                    return
                }
            } else {
                returnError(text: message(code: 'is.acceptanceTest.error.state.not.exist'))
                return
            }
        }
        AcceptanceTest.withTransaction {
            if (newState) {
                acceptanceTest.stateEnum = newState
            }
            bindData(acceptanceTest, acceptanceTestParams, [include: ['name', 'description']])
            acceptanceTestService.update(acceptanceTest)
        }
        withFormat {
            html {
                // TODO suggest story done when last acceptance test done
//                    if (request.productOwner && story.testStateEnum == Story.TestState.SUCCESS) {
//                        responseData.dialogSuccess = g.render(template: 'dialogs/suggestDone', model: [storyId: story.id])
//                    }
                render(status: 200, contentType: 'application/json', text: acceptanceTest as JSON)
            }
            json { renderRESTJSON text:acceptanceTest }
            xml  { renderRESTXML text:acceptanceTest }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def delete(long id, long product) {
        AcceptanceTest acceptanceTest = AcceptanceTest.withAcceptanceTest(product, id)
        def deleted = [id: acceptanceTest.id,parentStory: [id:acceptanceTest.parentStory.id]]
        acceptanceTestService.delete(acceptanceTest)
        withFormat {
            html { render status: 200, contentType: 'application/json', text: deleted as JSON }
            json { render status: 204 }
            xml  { render status: 204 }
        }
    }
}
