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
    <div class="d-flex justify-content-end">
        <div class="flex-grow-1 nb-pages">{{ currentPage + '/' + totalPages }}</div>
        <div class="mb-3">
            <button class="btn btn-secondary btn-sm" ng-click="prevPage()"><i class="fa fa-angle-left"></i></button>
            <button class="btn btn-secondary btn-sm" ng-click="nextPage()"><i class="fa fa-angle-right"></i></button>
            <button class="btn btn-secondary btn-sm" ng-click="zoomIn()"><i class="fa fa-search-plus"></i></button>
            <button class="btn btn-secondary btn-sm" ng-click="zoomOut()"><i class="fa fa-search-minus"></i></button>
            <a href="{{ pdfURL }}" class="btn btn-secondary btn-sm ml-3">download</a>
        </div>
    </div>
    <div class="pdf-viewer mt-2">
        <pdfviewer src="{{ pdfURL }}" on-page-load='pageLoaded(page,total)' id="viewer" width="page-fit"></pdfviewer>
    </div>
</is:modal>
</script>
<script type="text/ng-template" id="attachment.preview.picture.html">
<is:modal title="{{ title }}">
    <div class="text-right">
        <a href="{{ srcURL }}" class="btn btn-secondary btn-sm mb-3">Download</a>
    </div>
    <div class="text-center mt-2">
        <img ng-src="{{ srcURL }}" style="max-width:100%" title="{{ title }}"/>
    </div>
</is:modal>
</script>