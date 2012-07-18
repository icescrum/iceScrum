<li class="navigation-search search" style="cursor: pointer;">
    <a class="search-button active-search"></a>
</li>
<jq:jquery>
  jQuery('#window-id-finder .search-button').click(function(){
        var $marginLefty = $('#search-panel');
        $marginLefty.animate({  right: parseInt($marginLefty.css('right'),10) == 0 ? - $marginLefty.outerWidth() : 0 } );
        $(this).toggleClass('active-search');
        $('#backlog-layout-window-finder').toggleClass('full');
  });
</jq:jquery>