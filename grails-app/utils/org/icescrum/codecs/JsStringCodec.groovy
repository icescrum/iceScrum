/*
 * Copyright (c) 2026 Kagilum SAS
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

package org.icescrum.codecs

/**
 * Escapes a value for a JavaScript string literal that may itself sit inside an HTML attribute, which
 * is the case for the {@code ng-init} and {@code onclick} attributes of the login, registration and
 * OAuth consent pages.
 *
 * Only {@code \\uXXXX} sequences are emitted, so the result contains no quote, angle bracket or
 * ampersand and therefore cannot terminate the surrounding attribute, element or string literal. Both
 * layers of decoding (HTML then JavaScript) give back the original value.
 *
 * Prefer this over chaining the built-in javascript and html codecs, whose exact escaping of quotes
 * differs between Grails versions and is not guaranteed to survive HTML attribute parsing.
 */
class JsStringCodec {

    static encode = { theTarget ->
        if (theTarget == null) {
            return ''
        }
        String value = theTarget.toString()
        StringBuilder encoded = new StringBuilder(value.length() + 16)
        for (int i = 0; i < value.length(); i++) {
            char character = value.charAt(i)
            if (needsEscaping(character)) {
                encoded.append(String.format('\\u%04x', (int) character))
            } else {
                encoded.append(character)
            }
        }
        return encoded.toString()
    }

    private static boolean needsEscaping(char character) {
        if (character < 0x20 || character == 0x7f) {
            return true
        }
        switch (character) {
            case '\'':
            case '"':
            case '\\':
            case '/': // Guards against a literal </script> when the value is inlined in a script element
            case '<':
            case '>':
            case '&':
            case '`':
            case '\u2028':
            case '\u2029':
                return true
            default:
                return false
        }
    }
}
