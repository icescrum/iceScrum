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

import java.security.SecureRandom

/**
 * Provides the signing secrets used by Spring Security (remember-me cookie signature, run-as token
 * validation). These must be unique per installation: a value that is committed to the repository is
 * public knowledge and therefore provides no protection at all.
 *
 * All methods are safe to call while Config.groovy is being parsed: they never throw, and degrade to
 * an in-memory random value when no secret can be persisted.
 */
class SecretKeys {

    private static final SecureRandom RANDOM = new SecureRandom()

    static String generate() {
        byte[] bytes = new byte[32]
        RANDOM.nextBytes(bytes)
        return bytes.encodeHex().toString()
    }

    /**
     * Reads the secret stored in {@code <directory>/<fileName>}, creating it with a fresh random value
     * the first time. Persisting it keeps already-issued remember-me cookies valid across a restart.
     *
     * Operators running several nodes must share the file (or set the key explicitly in the external
     * iceScrum configuration), otherwise each node signs cookies with a different secret.
     */
    static String persistent(Object directory, String fileName) {
        if (!(directory instanceof CharSequence) || !directory.toString().trim()) {
            return generateWithWarning("no iceScrum base directory is configured")
        }
        File file = new File(directory.toString().trim(), fileName)
        try {
            if (file.exists()) {
                String existing = file.text?.trim()
                if (existing) {
                    return existing
                }
            }
            file.parentFile?.mkdirs()
            // Restrict before writing, so the secret is never on disk under the default umask
            file.createNewFile()
            restrictToOwner(file)
            String generated = generate()
            file.setText(generated, 'UTF-8')
            println "| Generated a new secret in ${file.canonicalPath} (keep it private, share it between nodes of a cluster)"
            return generated
        } catch (Exception e) {
            return generateWithWarning("${file.absolutePath} could not be read or written (${e.message})")
        }
    }

    private static String generateWithWarning(String reason) {
        println "| WARNING: using a randomly generated secret for this JVM because ${reason}."
        println "| WARNING: remember-me cookies will be invalidated on every restart. Set"
        println "| WARNING: grails.plugin.springsecurity.rememberMe.key in the iceScrum configuration file to avoid this."
        return generate()
    }

    private static void restrictToOwner(File file) {
        try {
            file.setReadable(false, false)
            file.setWritable(false, false)
            file.setExecutable(false, false)
            file.setReadable(true, true)
            file.setWritable(true, true)
        } catch (Exception ignored) {
            // Best effort: some filesystems do not support per-owner permissions
        }
    }
}
