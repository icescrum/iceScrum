%{--
- Copyright (c) 2016 Kagilum.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<script type="text/ng-template" id="sprint.multiple.html">
<div class="panel panel-light">
    <div class="panel-heading">
        <h3 class="panel-title">
            ${ message(code: 'todo.is.ui.sprints') } ({{ sprints.length }})
        </h3>
    </div>
    <div class="panel-body">
        <div class="table-responsive">
            <table class="table">
                <tr><td>${message(code: 'is.release')}</td><td>{{ release.name }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.startDate')}</td><td>{{ startDate | dateShort }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.endDate')}</td><td>{{ endDate | dateShort }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.story.sum')}</td><td>{{ sumStory }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.story.mean')}</td><td>{{ meanStory }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.velocity.mean')}</td><td>{{ meanVelocity }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.sprint.multiple.capacity.mean')}</td><td>{{ meanCapacity }}</td></tr>
            </table>
        </div>
    </div>
</div>
</script>