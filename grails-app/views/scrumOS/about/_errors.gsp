<is:table class="buildinfos-table">
    <is:tableHeader name="${message(code:'is.dialog.about.errors.name')}"/>
    <is:tableHeader name="${message(code:'is.dialog.about.errors.message')}"/>
    <is:tableRows in="${errors}" var="error">
        <is:tableColumn>
            ${g.message(code:error.title)}
            <g:if test="${error.version}">
                ${' (R'+error.version?.replaceFirst('\\.','#')+')'}
            </g:if>
        </is:tableColumn>
        <is:tableColumn>
            ${error.message.startsWith('is.') ? g.message(code:error.message, args:error.args?:null) : error.message}
            <g:if test="${error.version}">
                <br/>
                <a href="${error.url}">${g.message(code:'is.warning.version.download')}</a>
            </g:if>
        </is:tableColumn>
    </is:tableRows>
</is:table>