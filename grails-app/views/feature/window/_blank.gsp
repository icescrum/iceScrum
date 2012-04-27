<div class="box-blank clearfix" style="display:${!features ? 'block' : 'none'};">
    <p>${message(code: 'is.ui.feature.blank.description')}</p>
    <table cellpadding="0" cellspacing="0" border="0" class="box-blank-button">
        <tr>
            <td class="empty">&nbsp;</td>
            <td>
                <is:button
                        type="link"
                        rendered="${request.productOwner}"
                        button="button-s button-s-light"
                        href="#${controllerName}/add"
                        title="${message(code:'is.ui.feature.blank.new')}"
                        alt="${message(code:'is.ui.feature.blank.new')}"
                        icon="create">
                    <strong>${message(code: 'is.ui.feature.blank.new')}</strong>
                </is:button>
            </td>
            <td class="empty">&nbsp;</td>
        </tr>
    </table>
    <entry:point id="${controllerName}-${actionName}-blank"/>
</div>