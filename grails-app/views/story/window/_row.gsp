<underscore id="tpl-postit-row-story">
    <li data-elemid="** story.id **" class="postit-row postit-row-story **# if($.icescrum.user.poOrSm && story.effort) { ** estimated **# } else { ** postit-row-story **# } **">
        <em>(** story.effort ** **# if(story.effort > 1) { **pts**# } else { **pt**# } **)</em>
        <span title="** story.name **" class="postit-icon **# if(story.feature){ ** postit-icon-** story.feature.color ** **# } else { ** postit-yellow **# } **"></span>
        ** story.uid ** - ** story.name **
    </li>
</underscore>