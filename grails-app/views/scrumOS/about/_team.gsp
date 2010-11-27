%{--
- Copyright (c) 2010 iceScrum Technologies.
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
- Vincent Barrier (vincent.barrier@icescrum.com)
--}%
<h3>
<g:message code="is.dialog.about.team.title"/></h3>
<g:each status="i" var="member" in="${team.member}">
  <div class="member" style="display:none;" elemID="${i}" id="member-${i}">

    <img class="ico" src="${(member.image != '')?resource(dir: 'infos', file: 'images/'+member.image):resource(dir: is.currentThemeImage(), file: 'avatar.png')}" />

    <p><strong>${member.firstName} ${member.lastName}</strong></p>

    <p>${member.role}</p>

    <g:if test="${member.to != ''}">
      <p><g:message code="is.dialog.about.team.member.off"/> ${member.from} - ${member.to}</p>
    </g:if>
    <g:else>
      <p><g:message code="is.dialog.about.team.member.on"/> ${member.from} </p>
    </g:else>

    <p><a class="email" target="_blank" href="mailto:${member.email}">${member.email}</a></p>
    <p class="description">${member.description}</p>
  </div>
</g:each>

<div class="members">
<g:each status="i" var="member" in="${team.member}">
  <div class="member-mini ui-selected" elemID="${i}" id="member-mini-${i}">
    <img class="ico" src="${(member.image != '')?resource(dir: 'infos', file: 'images/'+member.image):resource(dir: is.currentThemeImage(), file: 'avatar.png')}" />
    <p><strong>${member.firstName} ${member.lastName}</strong></p>
    <p>${member.role}</p>
  </div>
</g:each>
</div>

<jq:jquery>
  $('.member .email').bind('click',function(event){
    event.stopPropagation();
  });

  $('.member-mini,.member').bind('click',function(){
      var id = $(this).attr('elemID');
      if ($('#member-'+id).is(':visible')){
        $('.member').hide();
        $('.member-mini').show();
      }else{
        $('.member-mini:hidden').show();
        $('#member-mini-'+id).hide();
        $('.member').hide();
        $('#member-'+id).show();
      }
    });
</jq:jquery>