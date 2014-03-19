<underscore id="tpl-story-row">
    <tr data-elemid="** story.id **"
        data-ui-popover
        data-ui-popover-placement="right"
        data-ui-popover-trigger="keep-hover"
        data-ui-popover-delay="500"
        data-ui-popover-html-content="#popover-story-row-** story.id ** > .content"
        data-ui-popover-html-title="#popover-story-row-** story.id ** > .title"
        class="row-story **# if($.icescrum.user.poOrSm && story.effort) { ** estimated **# } **">
        <td class="drag text-muted" style="border-left: 4px solid **# if(story.feature){ ** ** story.feature.color ** **# } else { ** none **# } **;padding-left: 2px;">
            <span class="glyphicon glyphicon-th"></span>
            <span class="glyphicon glyphicon-th"></span>
            <span class="glyphicon glyphicon-th"></span>
            <span class="glyphicon glyphicon-th"></span>
        </td>
        <td>** story.uid **</td>
        <td>** story.name ** **# if(story.effort > 1) { ** (** story.effort ** pts) **# } **</td>
        <td id="popover-story-row-** story.id **" class="hidden">
            <div class="title">
                ** story.name **
            </div>
            <div class="content">
                ** story.description **
            </div>
        </td>
    </tr>
</underscore>