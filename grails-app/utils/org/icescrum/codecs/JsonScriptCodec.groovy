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
 * Makes serialized JSON safe to embed inside an HTML {@code <script>} element.
 *
 * JSON escaping alone is not enough there: the HTML parser looks for {@code </script} before any
 * JavaScript runs, so a string value coming from the database (a user name, a project name, ...) can
 * close the script element. U+2028 and U+2029 are also escaped because they terminate a JavaScript
 * line even though JSON accepts them raw.
 *
 * The replacements produce {@code \\uXXXX} sequences, which are valid in both JSON and JavaScript
 * string literals and decode back to the original character, so the parsed value is unchanged.
 * Applying this to a whole JSON document is safe because none of the replaced characters can appear
 * outside a JSON string literal.
 */
class JsonScriptCodec {

    static encode = { theTarget ->
        if (theTarget == null) {
            return 'null'
        }
        String json = theTarget.toString()
        StringBuilder encoded = null
        for (int i = 0; i < json.length(); i++) {
            char character = json.charAt(i)
            String replacement = replacementFor(character)
            if (replacement == null) {
                encoded?.append(character)
            } else {
                if (encoded == null) {
                    encoded = new StringBuilder(json.length() + 32)
                    encoded.append(json, 0, i)
                }
                encoded.append(replacement)
            }
        }
        return encoded == null ? json : encoded.toString()
    }

    private static String replacementFor(char character) {
        switch (character) {
            case '<': return '\\u003c'
            case '>': return '\\u003e'
            case '&': return '\\u0026'
            case '\u2028': return '\\u2028'
            case '\u2029': return '\\u2029'
            default: return null
        }
    }
}
