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
 */

package org.icescrum.core.services.test

import grails.test.GrailsUnitTestCase

import org.springframework.util.ResourceUtils
import org.custommonkey.xmlunit.XMLUnit
import org.custommonkey.xmlunit.Diff
import org.icescrum.core.domain.Actor
import org.icescrum.core.domain.Cliche
import org.icescrum.core.domain.Feature
import org.icescrum.core.domain.Impediment
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Release
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Sprint
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User

class ExportXMLServiceTests extends GrailsUnitTestCase {
  def exportXMLService
  def fileContent
  def ruMock
  def fMock
  String testPath
  Date fixedDate = new Date()
  def fixedCalendar = new GregorianCalendar()
  def expectedXMLContent = """<product id="1">
  <isVersion>R2#16</isVersion>
  <productName>test</productName>
  <productPlanningPoker>1</productPlanningPoker>
  <productStartDate>${fixedDate.format('yyyy-MM-dd')}</productStartDate>
  <productDisableJoin>false</productDisableJoin>
  <productIsHidden>false</productIsHidden>
  <productEnableRole>true</productEnableRole>
  <release id="1">
    <releaseName>rr</releaseName>
    <releaseState>1</releaseState>
    <releaseStartDate>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</releaseStartDate>
    <releasePublishDate>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</releasePublishDate>
    <releaseVelocity>0.0</releaseVelocity>
    <releaseEstimatedSprintDuration>14</releaseEstimatedSprintDuration>
    <releaseVision/>
    <releaseGoal>do this</releaseGoal>
    <sprint id="1">
      <sprintRetrospective/>
      <sprintFinishDefinition/>
      <sprintNumber>1</sprintNumber>
      <sprintStartDate>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</sprintStartDate>
      <sprintEndDate>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</sprintEndDate>
      <sprintState>1</sprintState>
      <sprintCapacity>0.0</sprintCapacity>
      <sprintNbUserStory>0</sprintNbUserStory>
      <sprintNbTechnical>0</sprintNbTechnical>
      <sprintNbDefect>0</sprintNbDefect>
      <sprintGoal>do that</sprintGoal>
      <sprintDailyWorkTime>8.0</sprintDailyWorkTime>
      <SprintMeasure>
        <SprintMeasure_jour>${fixedCalendar.get(Calendar.DAY_OF_MONTH)}:${fixedCalendar.get(Calendar.MONTH)}:${fixedCalendar.get(Calendar.YEAR)}</SprintMeasure_jour>
        <SprintMeasure_NBTasks>0</SprintMeasure_NBTasks>
        <SprintMeasure_NBTasksDone>0</SprintMeasure_NBTasksDone>
      </SprintMeasure>
      <story id="1">
        <storyLabel>Story0</storyLabel>
        <storyDescription/>
        <storyCreationDate>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</storyCreationDate>
        <storyType>0</storyType>
        <storyRank>-999</storyRank>
        <storyState>5</storyState>
        <storyActiveRelease>false</storyActiveRelease>
        <storyOwner>1</storyOwner>
        <storyEstimationDate>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</storyEstimationDate>
        <storyEstimatedPoints>1</storyEstimatedPoints>
        <task id="1">
          <taskLabel>t1</taskLabel>
          <taskCreator>1</taskCreator>
          <taskState>0</taskState>
          <taskOwner>1</taskOwner>
        </task>
      </story>
    </sprint>
  </release>
  <theme id="1">
    <themeName>A certain feature</themeName>
    <themeColor>#FFFFFF</themeColor>
    <themeTextColor> </themeTextColor>
    <themeEstimatedPoints>-5</themeEstimatedPoints>
  </theme>
  <customRole id="1">
    <customRoleName>Chicken</customRoleName>
    <customRoleInstances>0</customRoleInstances>
    <customRoleSatisfactionCriteria/>
    <customRoleExpertnessLevel>1</customRoleExpertnessLevel>
    <customRoleUserFrequency>2</customRoleUserFrequency>
  </customRole>
  <story id="2">
    <storyLabel>Story1</storyLabel>
    <storyDescription/>
    <storyCreationDate>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</storyCreationDate>
    <storyType>0</storyType>
    <storyRank>-999</storyRank>
    <storyState>1</storyState>
    <storyActiveRelease>false</storyActiveRelease>
    <storyOwner>1</storyOwner>
    <storyEstimatedPoints>-5</storyEstimatedPoints>
    <storyTheme>1</storyTheme>
  </story>
  <problem id="1">
    <problemName>prob1</problemName>
    <problemRank/>
    <problemState>1</problemState>
    <problemDateOpen>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</problemDateOpen>
    <problemPoster>1</problemPoster>
    <problemDateModif>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</problemDateModif>    
  </problem>
  <cliche id="1">
    <clicheFonctionalStoryEstimatedVelocity>0</clicheFonctionalStoryEstimatedVelocity>
    <clicheDefectEstimatedVelocity>0</clicheDefectEstimatedVelocity>
    <clicheTechnicalStoryEstimatedVelocity>0</clicheTechnicalStoryEstimatedVelocity>
    <clicheFonctionalStoryBacklogPoints>0</clicheFonctionalStoryBacklogPoints>
    <clicheDefectBacklogPoints>0</clicheDefectBacklogPoints>
    <clicheTechnicalStoryBacklogPoints>0</clicheTechnicalStoryBacklogPoints>
    <clicheFonctionalStoryProductRemainingPoints>0</clicheFonctionalStoryProductRemainingPoints>
    <clicheDefectProductRemainingPoints>0</clicheDefectProductRemainingPoints>
    <clicheTechnicalStoryProductRemainingPoints>0</clicheTechnicalStoryProductRemainingPoints>
    <clicheFonctionalStoryReleaseRemainingPoints>0</clicheFonctionalStoryReleaseRemainingPoints>
    <clicheDefectReleaseRemainingPoints>0</clicheDefectReleaseRemainingPoints>
    <clicheTechnicalStoryReleaseRemainingPoints>0</clicheTechnicalStoryReleaseRemainingPoints>
    <clicheFinishedStories>0</clicheFinishedStories>
    <clicheLockedStories>0</clicheLockedStories>
    <clichePlannedStories>0</clichePlannedStories>
    <clicheEstimatedStories>0</clicheEstimatedStories>
    <clicheValidatedStories>0</clicheValidatedStories>
    <clicheIdentifiedStories>0</clicheIdentifiedStories>
    <clicheWrittenTests>0</clicheWrittenTests>
    <clicheProblems>0</clicheProblems>
    <clicheResource>0</clicheResource>
    <clicheDate>${fixedDate.format('yyyy-MM-dd HH:mm:ss')}</clicheDate>
  </cliche>
  <role id="1">
    <roleUser>1</roleUser>
    <roleName>2</roleName>
  </role>
  <user id="1">
    <userFirstName>John</userFirstName>
    <userLastName>Doe</userLastName>
    <userEmail>abdb@mail.com</userEmail>
    <userLogin>a</userLogin>
    <userPwd>ffvdsbsnbtdfgdfgdfgdfgdfa</userPwd>
    <userEnabled>true</userEnabled>
    <userLanguage>en</userLanguage>
  </user>
</product>
"""

  protected void setUp() {
    super.setUp()

    exportXMLService = new ExportXMLService()
    fixedCalendar.time = fixedDate
    
    // Mock messageSource, only used for the version string,
    // so we return a random version for testing purpose
    exportXMLService.messageSource = [getMessage: {Object[] o -> return 'R2#16'}]

    // Mock File and ResourceUtils classes, because ExportXMLService will normally return a file, but
    // we don't want it to be actually created for the unit test
    testPath = ResourceUtils.getFile('').absolutePath  + File.separator + 'test' + File.separator + 'unit' + File.separator + 'tmp'
    ruMock = mockFor(ResourceUtils)
    // Mock the static method getFile, it will always return the same path (/test/unit/tmp)
    // A dummy directory (fictive) is appended because exportXMLService is browsing back before actually creating the file
    ruMock.demand.static.getFile(0..2) {-> return new File(testPath + File.separator + 'dummy') }
    ruMock.demand.static.getFile(0..2) {String str -> return new File(testPath + File.separator + 'dummy') }
    ruMock.demand.static.getFile(0..2) {URI str -> return new File(testPath + File.separator + 'dummy') }
  }

  protected void tearDown() {
    super.tearDown()
  }

  void testExportProduct() {
    // Domain classes mock
    mockDomain(Story)
    mockDomain(User)
    mockDomain(Task)
    mockDomain(RemainingEstimationArray)
    mockDomain(Test)
    mockDomain(ExecTest)
    mockDomain(Product)
    mockDomain(Feature)
    mockDomain(Impediment)
    mockDomain(Cliche)
    mockDomain(Release)
    mockDomain(Sprint)
    mockDomain(SprintMeasure)
    mockDomain(Actor)
    mockDomain(Build)

    // "Mock" the methods of File so it won't actually create a file
    registerMetaClass File
    File.metaClass.constructor {String s -> }
    File.metaClass.getAbsolutePath { testPath + File.separator + 'dummy'}
    File.metaClass.write { String str -> fileContent = str}
    File.metaClass.getText { fileContent }
    File.metaClass.mkdirs { true }

    // Initialize test data
    // User
    def user = new User(username: "a",
            email: "abdb@mail.com",
            password: "ffvdsbsnbtdfgdfgdfgdfgdfa",
            language: "en")
    user.save()

    // Product
    def product = new Product(name: "test", startDate: fixedDate)
    product.save()

    // Impediment
    def prob = new Impediment(backlog:product, creator:user, name:'prob1', dateOpen:fixedDate)
    prob.save()
    prob.editionDate = fixedDate
    product.addToImpediments(prob)

    // Actor
    def cr = new Actor(product:product, name:'Chicken')
    cr.save()
    product.addToActors(cr)

    // Feature (feature)
    def th = new Feature(backlog: product, name: 'A certain feature')
    th.save()
    product.addToFeatures(th)

    // Release
    def release = new Release(backlog: product, name: "rr", startDate: fixedDate, endDate: fixedDate, goal: "do this")
    release.save()
    product.addToReleases(release)

    // Sprints
    def sprint = new Sprint(parentRelease: release, goal: "do that", orderNumber: 1, state: Sprint.STATE_WAIT, startDate: fixedDate, endDate: fixedDate)
    assertTrue sprint.validate()
    sprint.save()
    release.addToSprints(sprint)

    // SprintMeasure
    def sprintMeasure = new SprintMeasure(sprint, fixedCalendar, 0, 0)
    sprintMeasure.save()
    sprint.addToSprintMeasureIndicator(sprintMeasure)

    // ProductBacklogItems
    def pbis = [
            new Story(name: 'Story0', backlog: product, parentSprint: sprint, creator: user, state: Story.STATE_INPROGRESS, estimatedDate: fixedDate),
            new Story(name: 'Story1', backlog: product, creator: user, feature:th, state: Story.STATE_SUGGESTED)
    ]
    // Set some estimated points to the sprints that are in state STATE_ESTIMATED or in a sprint
    pbis[0].effort = 1
    pbis*.save(flush: true)
    pbis*.creationDate = fixedDate
    pbis.each { product.addToStories(it) }
    th.addToStories(pbis[1])
    sprint.addToStories(pbis[0])

    // Task
    def task = new Task(name:'t1', responsible:user, creator:user, parentStory:pbis[0])
    task.save()
    pbis[0].addToTasks(task)

    // Cliche
    def cliche = new Cliche(
            datePrise:fixedDate,
            backlog:product
    )
    cliche.save()
    product.addToCliches(cliche)

    def progressBar = new Expando()
    progressBar.value = { progressValue }
    progressBar.setValue = { val ->
      progressValue = val
      //pushInvoke('user_chan_' + this.user.id.toString(), { })
    }
    progressBar.active = false
    progressBar.action = {}

    // create the mock for the ResourceUtils
    ruMock.createMock()
    def xml = exportXMLService.exportProduct(product, user, progressBar)

    // Check that the xml file is similare to the expected result (tag orderNumber not strictly compared)
    XMLUnit.ignoreWhitespace = true
    
    // XMLUnit Diff doesn't like the <?xml ?> tag, so we have to remove it beforehand
    def xmlContent = xml.text.replaceFirst(/<\?xml.+\?>[\n\r]*/, '')
    def xmlDiff = new Diff(expectedXMLContent, xmlContent)
    assertTrue 'Generated XML is not equals to the XML code expected.', xmlDiff.similar()
  }
}
