<div class="dropmenu %{--
  - Copyright (c) 2010 iceScrum Technologies.
  -
  - This file is part of iceScrum.
  -
  - iceScrum is free software: you can redistribute it and/or modify
  - it under the terms of the GNU Lesser General Public License as published by
  - the Free Software Foundation, either version 3 of the License.
  -
  - iceScrum is distributed in the hope that it will be useful,
  - but WITHOUT ANY WARRANTY; without even the implied warranty of
  - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  - GNU General Public License for more details.
  -
  - You should have received a copy of the GNU Lesser General Public License
  - along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
  --}%

${classdrop}" id="dropmenu-${id}">
  <span class="dropmenu-arrow">!</span>
  <div class="dropmenu-content ui-corner-all">
      <ul class="small">${menuItems}</ul>
  </div>
</div>
<jq:jquery>
  $("#dropmenu-${id}").dropmenu({top: ${top}, yoffset: ${yoffset}, noWindows:${noWindows}});
</jq:jquery>