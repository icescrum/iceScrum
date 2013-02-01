<is:dialog width="510" valid="[action:'delete',
        controller:'story',
        onSuccess:'jQuery.event.trigger(\'remove_story\',[data]); jQuery.icescrum.renderNotice(\''+message(code:'is.story.deleted')+'\');',
        button:'is.dialog.storyDelete.confirm']">
    <form method="post" class="box-form box-form-250 box-form-160-legend" onsubmit="return false;">
        <input type="hidden" value="${params.product}" name="product"/>
        <g:each in="${params.list('id')}">
            <input type="hidden" value="${it}" name="id"/>
        </g:each>
        <is:fieldset title="is.dialog.storyDelete.title">
            <is:fieldInformation noborder="true">
                <g:message code="is.dialog.storyDelete.description"/>
            </is:fieldInformation>
            <is:fieldArea label="is.dialog.storyDelete.reason" for="reason" noborder="true">
                <is:area id="delete-reason" style="height: 70px; width: 256px;" name="reason" value=""/>
            </is:fieldArea>
        </is:fieldset>
    </form>
</is:dialog>