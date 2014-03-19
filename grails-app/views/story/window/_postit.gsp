<%@ page import="org.icescrum.core.domain.Story" %>
<underscore id="tpl-postit-story">
    <div data-elemid="** story.id **" class="item story col-xs-4 col-lg-4 ui-selectee **# if($.icescrum.o.showAsGrid) { ** grid-group-item **# } else { ** list-group-item **# } ** ">
        ** story.name **
    </div>
</underscore>