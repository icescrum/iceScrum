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

import groovy.util.XmlSlurper

/**
 * Builds XmlSlurper instances that cannot be used to reach the filesystem or the network.
 *
 * A default XmlSlurper resolves document type declarations and external entities, so parsing a
 * document that iceScrum did not produce (an RSS feed, an imported project) would let the document
 * author read local files or issue requests from the server.
 */
class SafeXml {

    private static final String DISALLOW_DOCTYPE = 'http://apache.org/xml/features/disallow-doctype-decl'
    private static final String EXTERNAL_GENERAL_ENTITIES = 'http://xml.org/sax/features/external-general-entities'
    private static final String EXTERNAL_PARAMETER_ENTITIES = 'http://xml.org/sax/features/external-parameter-entities'
    private static final String LOAD_EXTERNAL_DTD = 'http://apache.org/xml/features/nonvalidating/load-external-dtd'

    static XmlSlurper slurper() {
        XmlSlurper slurper = new XmlSlurper()
        setFeature(slurper, DISALLOW_DOCTYPE, true)
        setFeature(slurper, EXTERNAL_GENERAL_ENTITIES, false)
        setFeature(slurper, EXTERNAL_PARAMETER_ENTITIES, false)
        setFeature(slurper, LOAD_EXTERNAL_DTD, false)
        return slurper
    }

    private static void setFeature(XmlSlurper slurper, String feature, boolean value) {
        try {
            slurper.setFeature(feature, value)
        } catch (Exception ignored) {
            // Not every SAX implementation knows every feature name; the others still apply
        }
    }
}
