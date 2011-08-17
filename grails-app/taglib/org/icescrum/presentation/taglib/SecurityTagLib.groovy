/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 *
 */

package org.icescrum.presentation.taglib

import org.icescrum.core.domain.security.Authority

import org.springframework.security.core.authority.GrantedAuthorityImpl

class SecurityTagLib {
  static namespace = 'is'

  def securityService
  def aclUtilService
  static final userAuthorities = [new GrantedAuthorityImpl(Authority.ROLE_USER)]

  def displayRole = {attrs ->
    def res = []
      if (request.admin) {
        res << message(code: 'is.role.admin')
      }
      else
      {
        if (securityService.archivedProduct(params.product)){
            res << message(code:'is.product.archived')
        }else{
            if (request.owner) {
              res << message(code: 'is.role.owner')
            }
            if (request.scrumMaster) {
              res << message(code: 'is.role.scrumMaster')
            }
            if (request.teamMember) {
              res << message(code: 'is.role.teamMember')
            }
            if (request.productOwner) {
              res << message(code: 'is.role.productOwner')
            }
            if (!res && request.stakeHolder) {
              res << message(code: 'is.role.stakeHolder')
            }
        }
      }
    out << res.join(', ')
  }


}