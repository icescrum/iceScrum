<table>
    <thead>
    <tr>
        <th width="50%">${message(code:'is.dialog.about.errors.name')}</th>
        <th width="50%">${message(code:'is.dialog.about.errors.message')}</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${errors}" var="error">
        <tr>
            <td>${g.message(code:error.title)}
                <g:if test="${error.version}">
                    ${' (R'+error.version?.replaceFirst('\\.','#')+')'}
                </g:if>
            </td>
            <td>${error.message.startsWith('is.') ? g.message(code:error.message, args:error.args?:null) : error.message}
                <g:if test="${error.version}">
                    <br/>
                    <a href="${error.url}">${g.message(code:'is.warning.version.download')}</a>
                </g:if>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>