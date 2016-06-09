<script type="text/ng-template" id="attachment.preview.pdf.html">
<is:modal title="{{ title }}">
    <div class="help-block">
        <a href="{{ pdfURL }}" class="btn btn-info"><i class="fa fa-download"></i></a>
        <div class="btn-group">
            <button class="btn btn-default" ng-click="prevPage()"><i class="fa fa-angle-left"></i></button>
            <button class="btn btn-default" ng-click="nextPage()"><i class="fa fa-angle-right"></i></button>
        </div>
        <span class="pull-right">{{ currentPage + '/' + totalPages }}</span>
    </div>
    <div class="pdf-viewer">
        <pdfviewer src="{{ pdfURL }}" on-page-load='pageLoaded(page,total)' id="viewer"></pdfviewer>
    </div>
    <div class="help-block clearfix">
        <a href="{{ pdfURL }}" class="btn btn-info"><i class="fa fa-download"></i></a>
        <div class="btn-group">
            <button class="btn btn-default" ng-click="prevPage()"><i class="fa fa-angle-left"></i></button>
            <button class="btn btn-default" ng-click="nextPage()"><i class="fa fa-angle-right"></i></button>
        </div>
        <span class="pull-right">{{ currentPage + '/' + totalPages }}</span>
    </div>
</is:modal>
</script>
<script type="text/ng-template" id="attachment.preview.picture.html">
<is:modal title="{{ title }}">
    <div class="help-block">
        <a href="{{ srcURL }}" class="btn btn-info"><i class="fa fa-download"></i></a>
    </div>
    <div class="text-center">
        <img ng-src="{{ srcURL }}" style="max-width:100%" title="{{ title }}"/>
    </div>
    <div class="help-block">
        <a href="{{ srcURL }}" class="btn btn-info"><i class="fa fa-download"></i></a>
    </div>
</is:modal>
</script>