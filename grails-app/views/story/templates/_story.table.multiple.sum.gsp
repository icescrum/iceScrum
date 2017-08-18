<script type="text/ng-template" id="story.table.multiple.sum.html">
    <div class="table-responsive">
        <table class="table">
            <thead>
                <th>${message(code:'todo.is.ui.story.multiple.table.title')}</th>
            </thead>
            <tbody>
                <tr><td>${message(code: 'is.story.effort')}</td><td>{{ stories | sumBy:'effort' }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.tasks')}</td><td>{{ stories | sumBy:'tasks_count' }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.acceptanceTests')}</td><td>{{ stories | sumBy:'acceptanceTests_count' }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.followers')}</td><td>{{ stories | sumBy:'followers_count' }}</td></tr>
                <tr><td>${message(code: 'todo.is.ui.backlogelement.attachments')}</td><td>{{ stories | sumBy:'attachments_count' }}</td></tr>
                <entry:point id="story-table-multiple-row"/>
            </tbody>
        </table>
    </div>
</script>