/*
 * Nextcloud - Android Client
 *
 * SPDX-FileCopyrightText: 2026 Alper Ozturk <alper.ozturk@nextcloud.com>
 * SPDX-FileCopyrightText: 2025 Jimly Asshiddiqy <jimly.asshiddiqy@accenture.com>
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */
rootProject.name = "MSHost Cloud Android"

pluginManagement {
    resolutionStrategy.eachPlugin {
        if (requested.id.id == "shot") useModule("com.karumi:shot:${requested.version}")
    }

    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        gradlePluginPortal()
        mavenCentral()
    }
}

val mshostLocalProperties = java.util.Properties().apply {
    val propertiesFile = file("local.properties")
    if (propertiesFile.isFile) propertiesFile.inputStream().use { load(it) }
}

@Suppress("UnstableApiUsage")
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        if ((providers.gradleProperty("mshostMavenMirror").orNull
                ?: mshostLocalProperties.getProperty("mshost.mavenMirror", "false")) == "true") {
            maven("https://maven-central.storage-download.googleapis.com/maven2/")
        } else {
            mavenCentral()
        }
        maven("https://jitpack.io")
    }
}

/*
Needed for local android library
includeBuild("../android-library") {
    dependencySubstitution {
        substitute(module("com.github.nextcloud:android-library"))
            .using(project(":library"))
    }
}
*/


/*
Needed for local android common library

includeBuild("../android-common") {
    dependencySubstitution {
        substitute(module("com.github.nextcloud.android-common:core"))
            .using(project(":core"))

        substitute(module("com.github.nextcloud.android-common:ui"))
            .using(project(":ui"))
    }
}
*/

include(":app", ":appscan")
