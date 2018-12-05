%{--
- Copyright (c) 2018 Kagilum.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Vincent Barrier (vbarrier@kagilum.com)
- Nicolas Noullet (nnoullet@kagilum.com)
--}%
<script type="text/ng-template" id="attachment.preview.pdf.html">
<is:modal title="{{ title }}">
    <div class="form-text">
        <a href="{{ pdfURL }}" class="btn btn-info"><i class="fa fa-download"></i></a>
        <div class="btn-group">
            <button class="btn btn-secondary" ng-click="prevPage()"><i class="fa fa-angle-left"></i></button>
            <button class="btn btn-secondary" ng-click="nextPage()"><i class="fa fa-angle-right"></i></button>
        </div>
        <span class="pull-right">{{ currentPage + '/' + totalPages }}</span>
    </div>
    <div class="pdf-viewer">
        <pdfviewer src="{{ pdfURL }}" on-page-load='pageLoaded(page,total)' id="viewer"></pdfviewer>
    </div>
    <div class="form-text clearfix">
        <a href="{{ pdfURL }}" class="btn btn-info"><i class="fa fa-download"></i></a>
        <div class="btn-group">
            <button class="btn btn-secondary" ng-click="prevPage()"><i class="fa fa-angle-left"></i></button>
            <button class="btn btn-secondary" ng-click="nextPage()"><i class="fa fa-angle-right"></i></button>
        </div>
        <span class="pull-right">{{ currentPage + '/' + totalPages }}</span>
    </div>
</is:modal>
</script>
<script type="text/ng-template" id="attachment.preview.picture.html">
<is:modal title="{{ title }}">
    <div class="form-text">
        <a href="{{ srcURL }}" class="btn btn-info"><i class="fa fa-download"></i></a>
    </div>
    <div class="text-center">
        <img ng-src="{{ srcURL }}" style="max-width:100%" title="{{ title }}"/>
    </div>
    <div class="form-text">
        <a href="{{ srcURL }}" class="btn btn-info"><i class="fa fa-download"></i></a>
    </div>
</is:modal>
</script>