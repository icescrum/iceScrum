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



package org.icescrum.core.domain.security

import org.apache.commons.lang.builder.HashCodeBuilder
import org.icescrum.core.domain.User

class UserAuthority implements Serializable {

	User user
	Authority authority

	boolean equals(other) {
		if (!(other instanceof UserAuthority)) {
			return false
		}

		other.user?.id == user?.id &&
			other.authority?.id == authority?.id
	}

	int hashCode() {
		def builder = new HashCodeBuilder()
		if (user) builder.append(user.id)
		if (authority) builder.append(authority.id)
		builder.toHashCode()
	}

	static UserAuthority get(long userId, long authorityId) {
		find 'from UserAuthority where user.id=:userId and authority.id=:authorityId',
			[userId: userId, authorityId: authorityId]
	}

	static UserAuthority create(User user, Authority authority, boolean flush = false) {
		new UserAuthority(user: user, authority: authority).save(flush: flush, insert: true)
	}

	static boolean remove(User user, Authority authority, boolean flush = false) {
		UserAuthority instance = UserAuthority.findByUserAndAuthority(user, authority)
		instance ? instance.delete(flush: flush) : false
	}

	static void removeAll(User user) {
		executeUpdate 'DELETE FROM UserAuthority WHERE user=:user', [user: user]
	}

	static void removeAll(Authority authority) {
		executeUpdate 'DELETE FROM UserAuthority WHERE authority=:authority', [authority: authority]
	}

	static mapping = {
        cache true
		id composite: ['authority', 'user']
		version false
	}
}
