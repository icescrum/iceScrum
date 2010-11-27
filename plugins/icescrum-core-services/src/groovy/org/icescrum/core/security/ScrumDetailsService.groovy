/*
 * Copyright (c) 2010 iceScrum Technologies.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Stéphane Maldini (stephane.maldini@icescrum.com)
 */


package org.icescrum.core.security;


import org.codehaus.groovy.grails.plugins.springsecurity.GormUserDetailsService
import org.icescrum.core.domain.security.Authority
import org.springframework.security.core.authority.GrantedAuthorityImpl
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.core.GrantedAuthority
import org.springframework.transaction.support.TransactionCallback
import org.springframework.transaction.support.TransactionTemplate
import org.springframework.transaction.TransactionStatus

class ScrumDetailsService extends GormUserDetailsService {


  UserDetails loadUserByUsername(String username, boolean loadRoles) throws UsernameNotFoundException {
		def callback = { TransactionStatus status ->
			loadUserFromSession(username, sessionFactory.currentSession, loadRoles)
		}
		new TransactionTemplate(transactionManager).execute(callback as TransactionCallback)
	}

	/**
	 * {@inheritDoc}
	 */
	UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		loadUserByUsername username, true
	}

	protected UserDetails loadUserFromSession(String username, session, boolean loadRoles) {
		def user = loadUser(username, session)
		Collection<GrantedAuthority> authorities = loadAuthorities(user, username, loadRoles)
        authorities.add(new GrantedAuthorityImpl(Authority.ROLE_USER))
		createUserDetails user, authorities
	}

}
