package org.icescrum.web.presentation.app

import grails.converters.JSON
import grails.converters.XML
import grails.plugins.springsecurity.Secured
import org.icescrum.core.domain.AcceptanceTest
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.User

class AcceptanceTestController {

    def springSecurityService
    def acceptanceTestService

    // TODO inProduct is probably to restrictive (what about SHs?)
    @Secured('inProduct()')
    def index = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }
        withAcceptanceTest { AcceptanceTest acceptanceTest ->
            withFormat {
                json { renderRESTJSON text:acceptanceTest }
                xml  { renderRESTXML text:acceptanceTest }
            }
        }
    }

    // TODO inProduct is probably to restrictive (what about SHs?)
    @Secured('inProduct()')
    def list = {
        if (request?.format == 'html'){
            render(status:404)
            return
        }
        def acceptanceTests = params.story ? AcceptanceTest.getAllInStory(params.long('product'), params.long('story')) : AcceptanceTest.getAllInProduct(params.long('product'))
        withFormat {
            json { renderRESTJSON text: acceptanceTests }
            xml  { renderRESTXML text: acceptanceTests }
        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def save = {
        withStory('story.id') { story ->

            if (story.state >= Story.STATE_DONE) {
                returnError(text: message(code: 'is.acceptanceTest.error.save.storyState'))
                return
            }

            def acceptanceTest = new AcceptanceTest()

            def state = params.acceptanceTest.int('state')
            if (state != null) {
                if (AcceptanceTest.AcceptanceTestState.exists(state)) {
                    AcceptanceTest.AcceptanceTestState newState = AcceptanceTest.AcceptanceTestState.byId(state)
                    if (newState > AcceptanceTest.AcceptanceTestState.TOCHECK && story.state != Story.STATE_INPROGRESS) {
                        returnError(text: message(code: 'is.acceptanceTest.error.update.state.storyState'))
                        return
                    }
                    acceptanceTest.stateEnum = newState
                } else {
                    returnError(text: message(code: 'is.acceptanceTest.error.state.not.exist'))
                    return
                }
            }

            bindData(acceptanceTest, this.params, [include:['name','description']], "acceptanceTest")
            User user = (User) springSecurityService.currentUser

            try {
                acceptanceTestService.save(acceptanceTest, story, user)
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
    }

    @Secured('inProduct() and !archivedProduct()')
    def update = {
        withAcceptanceTest { AcceptanceTest acceptanceTest ->

            def story = acceptanceTest.parentStory
            if (story.state >= Story.STATE_DONE) {
                returnError(text: message(code: 'is.acceptanceTest.error.update.storyState'))
                return
            }

            def state = params.acceptanceTest.int('state')
            if (state != null) {
                if (AcceptanceTest.AcceptanceTestState.exists(state)) {
                    AcceptanceTest.AcceptanceTestState newState = AcceptanceTest.AcceptanceTestState.byId(state)
                    if (newState > AcceptanceTest.AcceptanceTestState.TOCHECK && story.state != Story.STATE_INPROGRESS) {
                        returnError(text: message(code: 'is.acceptanceTest.error.update.state.storyState'))
                        return
                    }
                    acceptanceTest.stateEnum = newState
                } else {
                    returnError(text: message(code: 'is.acceptanceTest.error.state.not.exist'))
                    return
                }
            }

            bindData(acceptanceTest, this.params, [include: ['name', 'description']], "acceptanceTest")
            User user = (User) springSecurityService.currentUser
            acceptanceTestService.update(acceptanceTest, user, acceptanceTest.isDirty('state'))

            withFormat {
                html {
                    def responseData = [acceptanceTest: acceptanceTest]
                    if (request.productOwner && story.testStateEnum == Story.TestState.SUCCESS) {
                        responseData.dialogSuccess = g.render(template: 'dialogs/suggestDone', model: [storyId: story.id])
                    }
                    render(status: 200, contentType: 'application/json', text: responseData as JSON)
                }
                json { renderRESTJSON text:acceptanceTest }
                xml  { renderRESTXML text:acceptanceTest }
            }

        }
    }

    @Secured('inProduct() and !archivedProduct()')
    def delete = {
        withAcceptanceTest { AcceptanceTest acceptanceTest ->

            def deleted = [id: acceptanceTest.id,parentStory: [id:acceptanceTest.parentStory.id]]
            acceptanceTestService.delete(acceptanceTest)

            withFormat {
                html { render status: 200, contentType: 'application/json', text: deleted as JSON }
                json { render status: 204 }
                xml  { render status: 204 }
            }
        }
    }

    // TODO check if it still usefull in the new UI
    @Secured('inProduct() and !archivedProduct()')
    def editor = {
        withAcceptanceTest { AcceptanceTest acceptanceTest ->
            render(template: '/acceptanceTest/acceptanceTestForm', model: [acceptanceTest: acceptanceTest, parentStory: acceptanceTest.parentStory])
        }
    }
}
