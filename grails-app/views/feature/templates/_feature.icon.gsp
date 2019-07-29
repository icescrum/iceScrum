%{--
- Copyright (c) 2019 Kagilum.
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

<script type="text/ng-template" id="feature.icon.html">
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="33" height="33" viewBox="0 0 33 33">
    <defs>
        <linearGradient id="feature-{{:: feature.color }}" x1="50%" x2="50%" y1="0%" y2="100%">
            <stop offset="0%" stop-color="{{:: feature.color | gradientColor }}"/>
            <stop offset="100%" stop-color="{{:: feature.color }}"/>
        </linearGradient>
    </defs>
    <g>
        <path fill="url(#feature-{{:: feature.color }})" fill-rule="nonzero" d="M16.8,8.233L16.8,5.556C16.8,4.618 16.045,3.856 15.113,3.856L12.623,3.856A0.434,0.434 0 0 1 12.243,3.214C12.454,2.838 12.556,2.394 12.506,1.921A2.156,2.156 0 0 0 10.622,0.014A2.147,2.147 0 0 0 8.238,2.157C8.238,2.542 8.338,2.902 8.513,3.214A0.434,0.434 0 0 1 8.133,3.857L5.643,3.857C4.712,3.857 3.957,4.617 3.957,5.557L3.957,8.145A0.432,0.432 0 0 1 3.29,8.51A2.114,2.114 0 0 0 1.998,8.176C0.925,8.246 0.054,9.141 0.003,10.223A2.15,2.15 0 0 0 2.141,12.486A2.11,2.11 0 0 0 3.299,12.141C3.582,11.956 3.957,12.172 3.957,12.512L3.957,15.1C3.957,16.039 4.712,16.8 5.643,16.8L15.113,16.8C16.045,16.8 16.8,16.04 16.8,15.1L16.8,12.423L16.8,8.233z" transform="
        scale(1.88)"/>
        <text x="58%" y="73%" text-anchor="middle">{{:: feature.uid }}</text>
    </g>
</svg>
</script>