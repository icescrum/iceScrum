/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vincent.barrier@icescrum.com)
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 */


package org.icescrum.core.test

import org.springframework.security.core.context.SecurityContextHolder as SCH

import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.icescrum.core.domain.preferences.ProductPreferences
import org.icescrum.core.domain.preferences.TeamPreferences
import org.icescrum.core.domain.preferences.UserPreferences
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.authority.AuthorityUtils

import grails.plugin.fluxiable.Activity
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.Team
import org.icescrum.core.domain.User
import org.icescrum.core.security.ScrumDetailsService
import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUser

class DummyPopulator {

  public static dummyze = {
    initDummyData()
  }

  private static void initDummyData() {

    println "Dummy Data loading...."

    def app = ApplicationHolder.application
    def springSecurityService = app.mainContext.springSecurityService
    def securityService = app.mainContext.securityService
    def sessionFactory = app.mainContext.sessionFactory
    def releaseService = app.mainContext.releaseService
    def sprintService = app.mainContext.sprintService
    def productBacklogService = app.mainContext.productBacklogService

    def ua, uz, ux
    if (User.count() <= 1) {
      ua = new User(username: "a",
              email: "a@gmail.com",
              enabled: true,
              firstName: "Roberto",
              password: springSecurityService.encodePassword('a'),
              preferences: new UserPreferences(language: 'en', activity: 'Consultant')
      ).save()
      uz = new User(username: "z",
              email: "z@gmail.com",
              enabled: true,
              firstName: "Bernardo",
              password: springSecurityService.encodePassword('z'),
              preferences: new UserPreferences(language: 'en', activity: 'WebDesigner', menu: ["sandbox": "1", "feature": "2", "productBacklog": "3"])
      ).save()
      ux = new User(username: "x",
              email: "x@gmail.com",
              enabled: true,
              firstName: "Antonio",
              password: springSecurityService.encodePassword('x'),
              preferences: new UserPreferences(language: 'en', activity: 'Consultant')
      ).save()
    }

    else {
      ua = User.findByUsername("a")
      uz = User.findByUsername("z")
      ux = User.findByUsername("x")
    }

    loginAsAdmin()

    if (Product.count() == 0) {


      def p = new Product(name: 'testProj')
      p.pkey = 'TESTPROJ'
      p.startDate = new Date().parse('yyyy-M-d', String.format('%tF', new Date()))
      p.preferences = new ProductPreferences()
      p.save()

      securityService.secureDomain(p)


      def team = new Team(name: 'testProj Team', preferences: new TeamPreferences()).addToProducts(p).addToMembers(ua).addToMembers(uz)
      team.save()
      securityService.secureDomain(team)


      def team2 = new Team(name: 'testProj Team2', preferences: new TeamPreferences()).addToProducts(p).addToMembers(ux)
      team2.save()
      securityService.secureDomain(team2)


        def team3 = new Team(name: 'empty Team3', preferences: new TeamPreferences()).addToMembers(ux)
      team3.save()
      securityService.secureDomain(team3)

      securityService.createScrumMasterPermissions(ux, team2)
      securityService.createTeamMemberPermissions(ux, team3)

      securityService.createProductOwnerPermissions(ua, p)
      securityService.createScrumMasterPermissions(ua, team)
      securityService.createTeamMemberPermissions(uz, team)

      securityService.changeOwner(ua, p)
      securityService.changeOwner(ua, team)
      securityService.changeOwner(ux, team2)


      def rel = new Release(startDate: new Date().parse('yyyy-M-d',
              String.format('%tF', new Date())), endDate: new Date().parse('yyyy-M-d', String.format('%tF', new Date())) + 120,
              goal: 'test Goal', description: 'bla', name: "dummy relesase")
      releaseService.saveRelease(rel, p)
      sprintService.generateSprints(rel)


      def feature = new Feature(name: 'La feature', value: 1, description: 'Une feature', backlog: p, rank: 1).save()
      def feature2 = new Feature(name: 'La feature 2', value: 1, description: 'Une feature', backlog: p, rank: 2, color: 'pink').save()
      def feature3 = new Feature(name: 'La feature 3', value: 1, description: 'Une feature', backlog: p, rank: 3, color: 'orange').save()

      p.addToFeatures(feature).addToFeatures(feature2).addToFeatures(feature3)

      def _storyCount = 0
      def s
      def createStory = {state ->
        s = new Story(backlog: p,
                feature: _storyCount % 4 == 0 ? feature : _storyCount % 3 == 0 ? feature3 : feature2,
                name: "A story $_storyCount",
                effort: 5,
                type: _storyCount % 6 == 0 ? Story.TYPE_TECHNICAL_STORY : _storyCount % 4 == 0  ? Story.TYPE_DEFECT : Story.TYPE_USER_STORY,
                creationDate: new Date(),
                suggestedDate: new Date(),
                estimatedDate: new Date(),
                state: state,
                creator: ua,
                rank: _storyCount++,
                description: 'As a user, I can do something awesome',
                notes: '<b>Un texte en gras</b> hahaha ! <em>et en italique</em>'
        ).save()
        s.addActivity(ua, state == Story.STATE_SUGGESTED ? Activity.CODE_SAVE :'acceptAs', s.name)

      }

      34.times {
        p.addToStories(createStory(it % 5 == 0 ? Story.STATE_SUGGESTED : Story.STATE_ESTIMATED))
      }
      p.save()

      sessionFactory.currentSession.flush()
      productBacklogService.autoPlan(rel, 20)

      int i = 0
      for (sp in rel.sprints) {
        sprintService.activeSprint(sp)

        for (pbi in sp.stories) {
          i.times {
            pbi.addToTasks(new Task(type:null,estimation:3,name:"task ${it} story : ${pbi.id}",creator:ua,responsible:ua,parentStory:pbi,backlog:sp,creationDate:new Date()))
          }
        }

        sp.addToTasks(new Task(type:Task.TYPE_RECURRENT,estimation:5,name:"task recurrent ${sp.id}",creator:ua,responsible:ua,parentStory:null,backlog:sp,creationDate:new Date()))
        sp.addToTasks(new Task(type:Task.TYPE_URGENT,estimation:4,name:"task urgent ${sp.id}",creator:ua,responsible:ua,parentStory:null,backlog:sp,creationDate:new Date()))

        if (i > 5)
          break

        2.times {
          p.addToStories(createStory(it % 3 == 0 ? Story.STATE_ACCEPTED : Story.STATE_ESTIMATED))
        }

        for (pbi in sp.stories) {
          pbi.state = Story.STATE_DONE
          pbi.tasks?.each { t ->
            t.state = Task.STATE_DONE
            t.estimation = 0
            t.doneDate = new Date()
          }
          pbi.save()
        }
        sprintService.closeSprint(sp)

        i++
      }

      p.stories.findAll{ (it.state == Story.STATE_ACCEPTED) || (it.state == Story.STATE_ESTIMATED)}.eachWithIndex{ it,index ->
        index++
        it.rank = index
        it.save()
      }
    }

    sessionFactory.currentSession.flush()
    SCH.clearContext()
  }

  private static void loginAsAdmin() {
    // have to be authenticated as an admin to create ACLs
    def userDetails = new GrailsUser('admin', 'adminadmin!', true, true, true, true, AuthorityUtils.createAuthorityList('ROLE_ADMIN'), 1)
    SCH.context.authentication = new UsernamePasswordAuthenticationToken(userDetails,'adminadmin!',AuthorityUtils.createAuthorityList('ROLE_ADMIN'))
  }

}
