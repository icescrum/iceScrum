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
import org.icescrum.core.domain.Product
import org.icescrum.core.domain.Story
import org.icescrum.core.domain.Task
import org.icescrum.core.domain.User
import org.icescrum2.domain.RemainingEstimationArray
import org.icescrum.core.services.TaskService

class TaskServiceTests extends GrailsUnitTestCase {
  def taskService
  Story storyTest
  Product productTest
  User userTest

  protected void setUp() {
    super.setUp()
    taskService = new TaskService()
    mockDomain(Task)
    mockDomain(Product)
    mockDomain(User)
    mockDomain(Story)
    mockDomain(RemainingEstimationArray)

    userTest = new User(username: "a",
            email: "abdb@mail.com",
            password: "dfvdfvdfvdfba",
            language: "en"
    )
    userTest.save()
    productTest = new Product(name: 'proj', startDate: new Date())
    productTest.save()
    storyTest = new Story (backlog: productTest, name: 'story', creator: userTest)
    storyTest.save()
  }

  public void testSaveTaskSprint() {
    int returnCode

    Task _task = new Task()
    _task.name = ''
    _task.transientEstimation = '5'

    returnCode = taskService.saveTask(_task, storyTest, productTest, userTest)
    assertEquals 'TaskService.saveTask did not return the expected result (NAME_REQUIRE): ', TaskService.NAME_REQUIRE, returnCode

    _task.name = 'Task1'
    _task.transientEstimation = '-1'
    returnCode = taskService.saveTask(_task, storyTest, productTest, userTest)
    assertEquals 'TaskService.saveTask did not return the expected result (TODO_NEGATIVE): ', TaskService.TODO_NEGATIVE, returnCode

    _task.transientEstimation = '5'
    returnCode = taskService.saveTask(_task, storyTest, productTest, userTest)
    assertEquals 'TaskService.saveTask did not return the expected result (VALIDATE): ', TaskService.VALIDATE, returnCode

    assertEquals 'BacklogBacklogItem getter did not return the expected result: ', storyTest, _task.parentStory
    assertEquals 'Creator getter did not return the expected result: ', userTest, _task.creator
    assertEquals 'Estimations getter did not return the expected result', new Integer(5), _task.estimations.getLast()
    assertEquals 'State getter did not return the expected result', new Integer(Task.STATE_WAIT), _task.state
    assertEquals 'Task not persisted even after being passed to saveTask()', 1, Task.count() 

    Task _task2 = new Task()
    _task2.transientEstimation = ' '
    _task2.name = 'Task2'
    returnCode = taskService.saveTask(_task2, storyTest, productTest, userTest)
    assertEquals 'TaskService.saveTask did not return the expected result (VALIDATE): ', TaskService.VALIDATE, returnCode
    assertEquals 'task estimation did not match with the expected result (NO_ESTIMATION): ', Task.NO_ESTIMATION, _task2.estimations.getLast()
  }
}
