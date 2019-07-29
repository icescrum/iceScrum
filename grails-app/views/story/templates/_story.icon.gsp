%{--
- Copyright (c) 2015 Kagilum.
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

<script type="text/ng-template" id="story.icon.html">
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="31" height="30" viewBox="0 0 31 30">
    <defs>
        <linearGradient id="story-{{:: story | storyColor }}" x1="50%" x2="50%" y1="0%" y2="100%">
            <stop offset="0%" stop-color="{{:: story | storyColor | gradientColor }}"/>
            <stop offset="100%" stop-color="{{:: story | storyColor }}"/>
        </linearGradient>
        <path id="c" d="M22.358 0l6.498 6.48h-6.498z"/>
        <filter id="b" width="207.7%" height="208%" x="-53.9%" y="-38.6%" filterUnits="objectBoundingBox">
            <feOffset dy="1" in="SourceAlpha" result="shadowOffsetOuter1"/>
            <feGaussianBlur in="shadowOffsetOuter1" result="shadowBlurOuter1" stdDeviation="1"/>
            <feColorMatrix in="shadowBlurOuter1" values="0 0 0 0 0.0666666667 0 0 0 0 0.0666666667 0 0 0 0 0.0666666667 0 0 0 0.356600996 0"/>
        </filter>
    </defs>
    <g fill="none" fill-rule="evenodd">
        <path fill="url(#story-{{:: story | storyColor }})" fill-rule="nonzero" d="M0 0h22.34l6.498 6.48v22.277H0z" transform="translate(0 1)"/>
        <g transform="translate(0 1)">
            <use fill="#000" filter="url(#b)" xlink:href="#c"/>
            <use fill="#FFF" xlink:href="#c"/>
        </g>
        <text x="47%" y="73%" text-anchor="middle">{{:: story.uid }}</text>
    </g>
</svg>
</script>