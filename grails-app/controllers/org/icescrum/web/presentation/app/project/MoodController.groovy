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

    // Current user mood by day for current last days
    def chart() {
        def user = (User) springSecurityService.currentUser
        def values = Mood.findAllByUser(user)
        def lastDays= new Date() - 14
        def computedValues = [[key   : message(code: 'todo.is.ui.mymood'),
                               values: values.findAll { it.feelingDay >= lastDays}.collect {
                                   return [it.feelingDay.time, it.feeling]
                               }]]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.moodUser.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.moodUser.xaxis.label')]],
                       title: [text: message(code: "is.chart.moodUser.title")]]
        def moodLabel = [message(code: "is.panel.mood.bad"), message(code: "is.panel.mood.meh"), message(code: "is.panel.mood.good")]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsY: moodLabel, options: options] as JSON)
    }

    def sprintUserMood(long product) {
        Product _product = Product.withProduct(product)
        def sprint = Sprint.findCurrentOrLastSprint(product).list()[0]
        def sprintActivationDate = sprint.activationDate.clone().clearTime()
        def values = Mood.findAllByUserInList(_product.allUsers).findAll { mood -> mood.feelingDay >= sprintActivationDate }
        // Mood by user
        def moodsByUser = values.groupBy { it.user }
        def computedValues = moodsByUser.collect { user, moods ->
            return [key: '', values: moods.collect { mood -> return [mood.feelingDay.time, mood.feeling] }]
        }
        // Mean mood
        def moodsByDay = values.groupBy { it.feelingDay }
        def listFellingByDay = [:]
        moodsByDay.each { feelingDay, moods ->
            listFellingByDay[feelingDay] = Math.round(moods.collect { Mood mood -> return mood.feeling }.sum() / moods.collect { Mood mood -> return mood.feeling }.size())
        }
        computedValues << [key: message(code: 'is.chart.sprintUserMood.teamMood'), values: listFellingByDay.collect { it -> return [it.key.time, it.value] }]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.sprintUserMood.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.sprintUserMood.xaxis.label')]],
                       title: [text: message(code: "is.chart.sprintUserMood.title")]]
        def moodLabel = [message(code: "is.panel.mood.bad"), message(code: "is.panel.mood.meh"), message(code: "is.panel.mood.good")]
        render(status: 200, contentType: 'application/json', text: [data: computedValues,labelsY: moodLabel, options: options] as JSON)
    }

    def releaseUserMood(long product) {
        def release = Release.findCurrentOrLastRelease(product).list()[0]
        Product _product = Product.withProduct(product)
        def sprintDone = Sprint.findAllByStateAndParentRelease(Sprint.STATE_DONE, release)
        def moodsOfTeam = Mood.findAllByUserInList(_product.allUsers)
        // Mood by user
        def moodsByUser = moodsOfTeam.groupBy { it.user }
        def meanMoodByUser = [:]
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
            return [key: '', values: means]
        }
        def listOfMoodBySprint = [:]
        def meanOfmoodBySprint = [:]
        // Mean mood
        sprintDone.each { sprint ->
            List<Integer> list = moodsOfTeam.findAll {
                it.feelingDay >= sprint.startDate && it.feelingDay <= sprint.endDate
            }.collect { return it.feeling }
            listOfMoodBySprint[sprint] = list
            meanOfmoodBySprint[sprint] = Math.round(list ? Math.round((list.sum() / list.size())) : 0)
        }
        computedValues << [key: message(code: 'is.chart.releaseUserMood.teamMood'), values: meanOfmoodBySprint.collect { sprint, mean -> return [mean] }]
        def options = [chart: [yAxis: [axisLabel: message(code: 'is.chart.releaseUserMood.yaxis.label')],
                               xAxis: [axisLabel: message(code: 'is.chart.releaseUserMood.xaxis.label')]],
                       title: [text: message(code: "is.chart.releaseUserMood.title")]]
        def sprintLabel = sprintDone.collect { message(code:'is.sprint') + ' ' + it.orderNumber }
        def moodLabel = [message(code: "is.panel.mood.bad"), message(code: "is.panel.mood.meh"), message(code: "is.panel.mood.good")]
        render(status: 200, contentType: 'application/json', text: [data: computedValues, labelsX: sprintLabel,labelsY: moodLabel, options: options] as JSON)
    }
}