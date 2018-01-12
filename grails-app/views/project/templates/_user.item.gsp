<script type="text/ng-template" id="user.item.project.html">
<div class="user">
    <img ng-src="{{ user | userAvatar }}" height="24" width="24" class="img-rounded user-role" title="{{ user.username }}">
    <span title="{{ user.username + ' (' + user.email + ')' }}" class="name">{{ user | userFullName }}</span>
    <a class="btn btn-danger btn-xs btn-model"
       ng-model="foo" %{-- Hack to make form dirty --}%
       ng-if="projectMembersEditable(project)"
       ng-click="removeUser(user, role);">
        <i class="fa fa-close"></i>
    </a>
</div>
</script>
<script type="text/ng-template" id="user.item.portfolio.html">
<div class="user">
    <img ng-src="{{ user | userAvatar }}" height="24" width="24" class="img-rounded user-role" title="{{ user.username }}">
    <span title="{{ user.username + ' (' + user.email + ')' }}" class="name">{{ user | userFullName }}</span>
    <a class="btn btn-danger btn-xs btn-model"
       ng-model="foo" %{-- Hack to make form dirty --}%
       ng-if="portfolioMembersEditable(portfolio)"
       ng-click="removeUser(user, role);">
        <i class="fa fa-close"></i>
    </a>
</div>
</script>