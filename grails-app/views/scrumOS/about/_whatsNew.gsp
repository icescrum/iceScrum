<is:dialog
        resizable="false"
        withTitlebar="false"
        width="600"
        id="dialog-whatsnew"
        buttons="'${message(code:'is.button.close')}': function() { ${remoteFunction(controller:'scrumOS',action:'whatsNew',params:[hide:true])}; jQuery(this).dialog('close'); }"
        draggable="false">
        <div class='box-form box-form-250 box-form-200-legend'>
            <is:fieldset title="is.ui.whatsnew.title" id="member-autocomplete">
                <is:fieldInformation noborder="true">${message(code:'is.ui.whatsnew.description', args:[g.meta(name:"app.version")])}</is:fieldInformation>
                <div class="features-list">
                    <ul>
                        <li>
                            <a href="" target="_blank"><img src=""></a>
                            <a href="" class="scrum-link" target="_blank">New 1</a>
                        </li>
                        <li>
                            <a href="" target="_blank"><img src=""></a>
                            <a href="" class="scrum-link" target="_blank">New 2</a>
                        </li>
                        <li>
                            <a href="" target="_blank"><img src=""></a>
                            <a href="" class="scrum-link" target="_blank">New 3</a>
                        </li>
                    </ul>
                    <span class="more">
                        <g:message code="is.ui.whatsnew.more"/> <a href="http://www.icescrum.org/en/version-r611" target="_blank" class="scrum-link">${message(code:"is.ui.whatsnew.releaseNotes", args:[g.meta(name:"app.version")])}</a>
                    </span>
                </div>
            </is:fieldset>
        </div>
</is:dialog>