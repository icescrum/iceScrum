/*
 * Copyright (c) 2026 Kagilum SAS.
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
 */

package org.icescrum.web

/**
 * Validates URLs that iceScrum is about to fetch on behalf of a user (RSS feeds, OAuth token
 * endpoints of self-hosted providers).
 *
 * Restricting the scheme is the part that can be enforced without knowing the deployment: without it,
 * a stored URL using file: or jar: turns an outbound fetch into a local file read. Restricting which
 * hosts may be reached is deployment-specific and belongs in the network egress policy; the optional
 * host allow list lets an operator express it here as well.
 */
class OutboundUrl {

    private static final List<String> ALLOWED_SCHEMES = ['http', 'https']

    /**
     * Returns the parsed URL, or throws IllegalArgumentException when it is not an absolute http(s)
     * URL or when {@code allowedHosts} is non-empty and does not contain its host.
     */
    static URL validate(String url, Collection<String> allowedHosts = null) {
        if (!url) {
            throw new IllegalArgumentException('Error, no URL was provided')
        }
        URL parsed
        try {
            parsed = new URL(url)
        } catch (MalformedURLException e) {
            throw new IllegalArgumentException("Error, ${url} is not a valid URL")
        }
        if (!(parsed.protocol?.toLowerCase() in ALLOWED_SCHEMES)) {
            throw new IllegalArgumentException("Error, only ${ALLOWED_SCHEMES.join(' and ')} URLs can be fetched")
        }
        if (!parsed.host) {
            throw new IllegalArgumentException("Error, ${url} has no host")
        }
        if (allowedHosts && !(parsed.host.toLowerCase() in allowedHosts*.toString()*.toLowerCase())) {
            throw new IllegalArgumentException("Error, ${parsed.host} is not an allowed host")
        }
        return parsed
    }
}
