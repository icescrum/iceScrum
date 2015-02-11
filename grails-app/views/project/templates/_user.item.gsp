<script type="text/ng-template" id="user.item.html">
<div class="user">
    <img ng-src="{{ user | userAvatar }}" height="24" width="24" title="{{ user.username }}">
    <span title="{{ user.username }} ({{ user.email }})" class="name">{{ user.firstName }} {{ user.lastName }}</span>
    <a class="btn btn-danger btn-xs" ng-click="removeUser(user, role);"><i class="fa fa-close"></i></a>
</div>
</script>