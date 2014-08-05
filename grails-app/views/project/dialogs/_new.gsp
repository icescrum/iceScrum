<is:modal title="${message(code:'is.dialog.wizard')}" class="wizard" footer="${false}">
    <form novalidate>
        <wizard class="row" on-finish="finishedWizard()" style="height:450px;">
            <wz-step title="${message(code:"is.dialog.wizard.section.project")}">
                <h4>${message(code:"is.dialog.wizard.section.project")}</h4>
                <p class="help-block">${message(code:'is.dialog.wizard.section.project.description')}</p>
                <div class="clearfix no-padding">
                    <div class="col-md-9 form-group">
                        <label for="product.name">${message(code:'is.product.name')}</label>
                        <input required
                               name="product.name"
                               type="text"
                               class="form-control"
                               ng-model="product.name">
                    </div>
                    <div class="col-md-3 form-group">
                        <label for="product.pkey">${message(code:'is.product.pkey')}</label>
                        <input required
                               name="product.pkey"
                               type="text"
                               class="form-control"
                               ng-model="product.pkey"
                               ng-readonly="readOnly()">
                    </div>
                </div>
                <div class="clearfix no-padding">
                    <div class="col-md-8 form-group">
                        <label for="product.preferences.timezone">${message(code:'is.product.preferences.timezone')}</label>
                        <select style="width:100%"
                                class="form-control"
                                ng-model="product.preferences.timezone"
                                ui-select2></select>
                    </div>
                    <div class="col-md-4 form-group">
                        <div class="checkbox">
                            <label for="product.preferences.hidden">
                                <input id="product.preferences.hidden" type="checkbox" name="product.preferences.hidden"> ${message(code:'is.product.preferences.project.hidden')}
                            </label>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <label for="product.startDate">${message(code:'is.product.startDate')}</label>
                        <p class="input-group">
                            <input type="text" class="form-control"
                                   datepicker-popup="{{dateOptions.format}}"
                                   ng-model="dt"
                                   is-open="dateOptions.opened"
                                   min-date="dateOptions.minDate"
                                   max-date="dateOptions.maxDate"
                                   datepicker-options="dateOptions"
                                   date-disabled="disabled(date, mode)"
                                   ng-required="true"
                                   close-text="Close" />
                            <span class="input-group-btn">
                                <button type="button" class="btn btn-default" ng-click="open($event)"><i class="glyphicon glyphicon-calendar"></i></button>
                            </span>
                        </p>
                    </div>
                    <div class="col-md-6">
                        <label for="product.startDate">${message(code:'is.product.startDate')}</label>
                        <p class="input-group">
                            <input type="text" class="form-control"
                                   datepicker-popup="{{dateOptions.format}}"
                                   ng-model="dt"
                                   is-open="dateOptions.opened"
                                   min-date="dateOptions.minDate"
                                   max-date="dateOptions.maxDate"
                                   datepicker-options="dateOptions"
                                   date-disabled="disabled(date, mode)"
                                   ng-required="true"
                                   close-text="Close" />
                            <span class="input-group-btn">
                                <button type="button" class="btn btn-default" ng-click="open($event)"><i class="glyphicon glyphicon-calendar"></i></button>
                            </span>
                        </p>
                    </div>
                </div>
                <div class="form-group">
                    <label for="product.description">${message(code:'is.product.description')}</label>
                    <textarea is-markitup
                              class="form-control"
                              placeholder="${message(code: 'todo.is.ui.product.description.placeholder')}"
                              ng-model="product.description"
                              ng-show="showDescriptionTextarea"
                              ng-blur="showDescriptionTextarea = false"
                              is-model-html="product.description_html"></textarea>
                    <div class="markitup-preview"
                         tabindex="0"
                         ng-show="!showDescriptionTextarea"
                         ng-click="showDescriptionTextarea = true"
                         ng-focus="showDescriptionTextarea = true"
                         ng-class="{'placeholder': !product.description_html}"
                         ng-bind-html="(product.description_html ? product.description_html : '<p>${message(code: 'todo.is.ui.product.description.placeholder')}</p>') | sanitize"></div>
                </div>
                <input type="submit" class="btn btn-default pull-right" wz-next value="Continue" />
            </wz-step>
            <wz-step title="${message(code:"is.dialog.wizard.section.team")}">
                <div class="row">
                    <div class="col-md-6">
                        <h4>${message(code:"is.dialog.wizard.section.team")}</h4>
                        <label for="team.name">${message(code:'is.team.name')}</label>
                        <input required
                               name="team.name"
                               type="text"
                               class="form-control"
                               ng-model="team.name">
                        <label for="">${message(code:'todo.is.ui.choose.member')}</label>
                        <p class="help-block">${message(code:'is.dialog.wizard.section.project.description')}</p>
                    </div>
                    <div class="col-md-6">
                        <h4>Team members <small>3 members</small></h4>
                        <table class="table table-striped">
                            <thead>
                            <tr>
                                <th></th>
                                <th>Name</th>
                                <th>Role</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>Avatar</td>
                                <td>Mark Otto</td>
                                <td>@mdo</td>
                            </tr>
                            <tr>
                                <td>Avatar</td>
                                <td>Jacob Thornton</td>
                                <td>@fat</td>
                            </tr>
                            <tr>
                                <td>Avatar</td>
                                <td>Larry the Bird</td>
                                <td>@twitter</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <input type="submit" class="btn btn-default pull-right" wz-next value="Go on" />
            </wz-step>
            <wz-step title="${message(code:"is.dialog.wizard.section.options")}">
                <input type="submit" class="btn btn-default pull-right" wz-next value="Finish now" />
            </wz-step>
            <wz-step title="${message(code:"is.dialog.wizard.section.starting")}">
                <input type="submit" class="btn btn-default pull-right" wz-next value="Finish now" />
            </wz-step>
        </wizard>
    </form>
</is:modal>