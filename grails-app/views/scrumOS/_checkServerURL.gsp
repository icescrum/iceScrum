%{--
- Copyright (c) 2014 Kagilum SAS.
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
<script type="text/javascript">
(function() {
var serverUrl = '${grailsApplication.config.grails.serverURL}';
    if (window.location.href.indexOf(serverUrl) == -1) {
        var grailsServerUrl = document.createElement('a');
        grailsServerUrl.href = serverUrl;
        var currentServerUrl = document.createElement('a');
        currentServerUrl.href = window.location.href;
        alert('Redirecting to the configured iceScrum Server URL: ' +  serverUrl);
        document.location = grailsServerUrl.protocol + '//' + grailsServerUrl.host + currentServerUrl.pathname + currentServerUrl.hash;
    }
})();
</script>