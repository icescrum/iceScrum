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
<underscore id="tpl-list-shortcuts">
    <is:modal title="${message(code:'todo.is.shortcuts')}" size="lg" name="shortcuts">
        <div class="row">
        **# _.each(shortcuts, function(shortcut, index){ **
            <div class="col-md-3 help-keys">
                <kdb class="help-key">
                    <span>** shortcut.key **</span>
                </kdb> <span>** shortcut.title **</span>
            </div>
            **# if ((index + 1) % 4 == 0){ ** </div>
                **# if(index < shortcuts.length){ ** <div class="row"> **# } **
            **# } **
        **# }); **
        **# if (shortcuts.length % 4 != 0){ ** </div> **# } **
    </is:modal>
</underscore>