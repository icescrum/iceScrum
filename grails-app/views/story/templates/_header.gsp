%{--
- Copyright (c) 2014 Kagilum.
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
--}%
<script type="text/icescrum-template" id="tpl-story-header-name">
<a href="${g.createLink(controller:'story', action:'follow', id:'**.story.id **', params: [product: '** jQuery.icescrum.product.pkey **'])}"
   data-status-toggle="fa-star"
   data-status-title="followers"><i class="fa fa-star-o"></i></a> <span>** story.name **</span><small>**# if (story.origin) { ** ${message(code:'is.story.origin')}: ** story.origin ** **# } **</small>
</script>