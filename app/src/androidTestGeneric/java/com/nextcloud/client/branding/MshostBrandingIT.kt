/*
 * SPDX-FileCopyrightText: 2026 MSHost contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
package com.nextcloud.client.branding

import android.content.res.Configuration
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.owncloud.android.R
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.net.URI
import java.util.Locale

@RunWith(AndroidJUnit4::class)
class MshostBrandingIT {
    private val context = InstrumentationRegistry.getInstrumentation().targetContext
    private val packageName = "io.github.bigshishka.mshostcloud"

    @Test
    fun applicationAndProvidersHaveIndependentIdentities() {
        assertEquals(packageName, context.packageName)
        assertEquals("MSHost Cloud", context.getString(R.string.app_name))
        val identities = listOf(
            R.string.account_type,
            R.string.authority,
            R.string.document_provider_authority,
            R.string.file_provider_authority,
            R.string.image_cache_provider_authority,
            R.string.users_and_groups_search_authority
        ).map(context::getString)
        assertEquals(identities.size, identities.toSet().size)
        assertTrue(identities.all { it.startsWith(packageName) })
    }

    @Test
    fun loginAndHelpUseMshostResources() {
        assertEquals("cloud.mshostcloud.org", URI(context.getString(R.string.suggested_server)).host)
        assertEquals("https", URI(context.getString(R.string.suggested_server)).scheme)
        assertTrue(context.resources.getBoolean(R.bool.show_server_url_input))
        assertTrue(context.resources.getBoolean(R.bool.is_branded_client))
        assertFalse(context.resources.getBoolean(R.bool.show_provider_or_own_installation))
        assertFalse(context.resources.getBoolean(R.bool.participate_enabled))
        assertTrue(context.resources.getBoolean(R.bool.license_enabled))
        listOf(R.string.url_help, R.string.sourcecode_url, R.string.url_app_download).forEach {
            assertTrue(context.getString(it).startsWith("https://github.com/BigShiShKa/mshost-cloud-android"))
        }
    }

    @Test
    fun russianAndEnglishProductLabelsUseMshost() {
        listOf("ru", "en").forEach { language ->
            val configuration = Configuration(context.resources.configuration).apply {
                setLocale(Locale.forLanguageTag(language))
            }
            val resources = context.createConfigurationContext(configuration).resources
            listOf(R.string.compose_activity_label, R.string.file_migration_failed_dir_already_exists).forEach {
                assertTrue(resources.getString(it).contains("MSHost Cloud"))
                assertFalse(resources.getString(it).contains("Nextcloud"))
            }
        }
    }
}
