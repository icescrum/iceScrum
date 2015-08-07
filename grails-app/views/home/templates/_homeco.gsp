%{--
- Copyright (c) 2015 Kagilum.
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
- Authors:Marwah Soltani (msoltani@kagilum.com)
-
--}%
<script type="text/ng-template" id="home.connected.html">
<div class="container">
    <div html-sortable class="row" id="panelhome">
        <div class="col-md-5">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code: 'is.panel.rss')}</div>

                <div class="panel-body">..</div>
            </div>
        </div>

        <div class="col-md-5">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code: 'is.panel.notes')}</div>

                <div><textarea rows="4" cols="50"></textarea></div>

                <div class="panel-body">..</div>
            </div>
        </div>

        <div class="col-md-7">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code: 'is.panel.myprojects')}</div>

                <div class="panel-body">..</div>
            </div>
        </div>

        <div class="col-md-7">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code: 'is.panel.mood')}</div>

                <div class="panel-body">..</div>
            </div>
        </div>

        <div class="col-md-5">
            <div class="panel panel-primary">
                <div class="panel-heading">${message(code: 'is.panel.mytask')}</div>

                <div ng-controller="Accordion">
                    <accordion close-others="oneAtATime">
                        <accordion-group>
                            <accordion-heading>
                                <i class="pull-right glyphicon"
                                   ng-class="{'glyphicon-chevron-down': status.open, 'glyphicon-chevron-right': !status.open}"></i>
                            </accordion-heading>
                        </accordion-group>
                        <accordion-group>
                            <accordion-heading>
                                <i class="pull-right glyphicon"
                                   ng-class="{'glyphicon-chevron-down': status.open, 'glyphicon-chevron-right': !status.open}"></i>
                            </accordion-heading>
                        </accordion-group>
                        <accordion-group>
                            <accordion-heading>
                                <i class="pull-right glyphicon"
                                   ng-class="{'glyphicon-chevron-down': status.open, 'glyphicon-chevron-right': !status.open}"></i>
                            </accordion-heading>
                        </accordion-group>
                        <accordion-group>
                            <accordion-heading>
                                <i class="pull-right glyphicon"
                                   ng-class="{'glyphicon-chevron-down': status.open, 'glyphicon-chevron-right': !status.open}"></i>
                            </accordion-heading>
                        </accordion-group>
                    </accordion>
                </div>
            </div>
        </div>
    </div>
</div>
</script>