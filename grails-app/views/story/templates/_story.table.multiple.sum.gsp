%{--
- Copyright (c) 2017 Kagilum.
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
<script type="text/ng-template" id="story.table.multiple.sum.html">
    <div class="table-responsive">
        <table class="table">
            <thead>
                <th>${message(code: 'todo.is.ui.story.multiple.table.title')}</th>
            </thead>
            <tbody>
                <tr><td>${message(code: 'is.story.effort')}</td><td>{{ stories | sumBy:'effort' }}</td></tr>
                <tr><td>${message(code: 'is.story.value')}</td><td>{{ stories | sumBy:'value' }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.backlogelement.attachments')}</td><td>{{ stories | sumBy:'attachments_count' }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.comments')}</td><td>{{ stories | sumBy:'comments_count' }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.tasks')}</td><td>{{ stories | sumBy:'tasks_count' }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.acceptanceTests')}</td><td>{{ stories | sumBy:'acceptanceTests_count' }}</td></tr>
                <entry:point id="story-table-multiple-row"/>
            </tbody>
        </table>
    </div>
</script>