/*
 * Copyright (c) 2015 Kagilum.
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
 * Marwah Soltani (msoltani@kagilum.com)
 *
 */
package org.icescrum.web.presentation.app.project
import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured
import org.icescrum.core.domain.Mood
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.User

@Secured('isAuthenticated()')
class MoodController {

    def springSecurityService

    def save() {
        Mood mood = new Mood()
        try {
            Mood.withTransaction {
                bindData(mood, params.mood, [include: ['feeling']])
                mood.user = (User) springSecurityService.currentUser
                mood.feelingDay = new Date()
                if (!mood.save(flush: true)) {
                    throw new RuntimeException(mood.errors?.toString())
                }
            }
            withFormat {
                html { render(status: 200, contentType: 'application/json', text: mood as JSON) }
                json { renderRESTJSON(status: 201, text: mood) }
                xml { renderRESTXML(status: 201, text: mood) }
            }
        } catch (IllegalStateException e) {
            returnError(exception: e)
        } catch (RuntimeException e) {
            returnError(object: mood, exception: e)
        }
    }

    def listByUser() {
        def today = new Date().clearTime()
        def moods = Mood.findAllByUserAndFeelingDay((User) springSecurityService.currentUser, today)
        render(status: 200, contentType: 'application/json', text: moods as JSON)
    }

    def isAlreadySavedToday() {
        def today = new Date().clearTime()
        def moodCount = Mood.countByFeelingDayAndUser(today, (User) springSecurityService.currentUser)
        render(status: 200, contentType: 'application/json', text: [value: moodCount > 0] as JSON)
    }

    def chart() {
        def user = (User) springSecurityService.currentUser
        def values = Mood.findAllByUser(user)
        def sprintInProgress = Sprint.findByState(Sprint.STATE_INPROGRESS)
        def sprintActivationDate = sprintInProgress.activationDate.clone().clearTime()
        def computedValues = [[key: message(code: 'todo.is.ui.mymood'),
                               values: values.findAll { it.feelingDay >= sprintActivationDate }.collect {
                                   return [it.feelingDay.time, it.feeling]
                               }]]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.moodUser.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.mooduser.xaxis.label')]],
                       title: [text: message(code: "is.chart.moodUser.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues , options :options] as JSON)
    }

    def chartUser(long product) {
        Product _product = Product.withProduct(product)
        def sprintInProgress = Sprint.findByState(Sprint.STATE_INPROGRESS)
        def sprintActivationDate = sprintInProgress.activationDate.clone().clearTime()
        def values = Mood.findAllByUserInList(_product.allUsers)
        def groupedByUser = values.groupBy { it.user }
        def computedValues = groupedByUser.collect { user, moods ->
            return [key   : user.username,
                    values: moods.findAll { mood -> mood.feelingDay >= sprintActivationDate }.collect { mood -> return [mood.feelingDay.time, mood.feeling] }]
        }


        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.moodSprint.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.moodSprint.xaxis.label')]],
                       title: [text: message(code: "is.chart.moodRelease.title")]]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, options: options] as JSON)
    }

    def chartUserRelease(long product) {

        def release = Release.findCurrentOrLastRelease(product).list()[0]
        Product _product = Product.withProduct(product)
        def sprintDone = Sprint.findAllByStateAndParentRelease(Sprint.STATE_DONE, release)

        def moodsOfTeam = Mood.findAllByUserInList(_product.allUsers)
        Map<User, List<Mood>> moodsByUser = moodsOfTeam.groupBy { it.user }
        def sprintLabel = sprintDone.collect { 'Sprint' + it.id }

        Map<User, List<Long>> meanMoodByUser = [:]
        moodsByUser.each { User user, List<Mood> moods ->
            meanMoodByUser[user] = []
            sprintDone.each { Sprint sprint ->
                List<Integer> moodsOfSprintForTheCurrentUser = moods.findAll { Mood mood ->
                    return mood.feelingDay >= sprint.startDate && mood.feelingDay <= sprint.endDate
                }.collect { Mood mood ->
                    return mood.feeling
                }
                meanMoodByUser[user] << [(moodsOfSprintForTheCurrentUser ? Math.round((moodsOfSprintForTheCurrentUser.sum() / moodsOfSprintForTheCurrentUser.size())) : 0)]
            }
        }

        def computedValues = meanMoodByUser.collect { user, means ->
            return [key: user.firstName, values: means]
        }
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.moodRelease.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.moodRelease.xaxis.label')]],
        title: [text: message(code: "is.chart.moodRelease.title")]]

        render(status: 200, contentType: 'application/json', text: [data: computedValues, labels: sprintLabel, options: options] as JSON)
    }

}
