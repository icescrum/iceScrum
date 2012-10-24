<li class="navigation-search search" style="cursor: pointer;">
    <a class="search-button active-search"></a>
</li>
<jq:jquery>
  jQuery('#window-id-finder .search-button').click(function(){
        var $marginLefty = $('#search-panel');
        $marginLefty.animate({  'margin-right': parseInt($marginLefty.css('margin-right'),10) == 0 ? - $marginLefty.outerWidth() : 0 }, { complete:function(){ $('#window-content-finder').trigger('resize'); } } );
        $(this).toggleClass('active-search');
  });
</jq:jquery>