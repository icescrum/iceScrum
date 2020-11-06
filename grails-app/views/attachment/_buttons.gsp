<div ng-if="project" class="d-flex justify-content-end">
    <a href
       ng-repeat="provider in getFilteredProviders()"
       ng-click="selectedProvider(provider)"
       ng-class="{'disabled': !provider.enabled}"
       class="attachment-provider-container">
        <span class="attachment-provider attachment-provider-{{ ::provider.id }}" title="{{ ::provider.name }}"></span>
    </a>
    <a ng-if="::providers && providers.length != 0"
       class="btn btn-secondary btn-sm plus-app"
       ng-click="showAppsModal(message('is.ui.apps.tag.attachments'), true)"
       href></a>
</div>