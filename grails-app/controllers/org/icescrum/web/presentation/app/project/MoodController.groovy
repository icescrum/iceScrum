package org.icescrum.web.presentation.app.project
import org.icescrum.core.domain.Mood

class MoodController {

    def springSecurityService
    def MoodService
        def save() {
            Mood mood  = new Mood()
            try {
                Mood.withTransaction {
                    bindData(mood, [include: ['moodUser', 'user']])
                    MoodService.save(mood, springSecurityService.currentUser)
                }
            } catch (IllegalStateException e) {
                returnError(exception: e)
            } catch (RuntimeException e) {
                returnError(object: task, exception: e)
            }
        }
    }
