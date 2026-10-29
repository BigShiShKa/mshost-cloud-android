<!--
SPDX-FileCopyrightText: 2026 MSHost contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->
# Сборка Android на Windows

Проверенное окружение: JDK 21 (локально 21.0.12), Gradle Wrapper 9.7.1,
AGP 9.4.1, Kotlin 2.4.20, compile SDK 37, build-tools 36.0.0,
NDK 29.0.14206865, CMake 4.1.2. Используйте версии из исходников и wrapper.
Java 25 из установленной Android Studio для этой сборки не использовалась.

Откройте проект в Android Studio, задайте SDK и JDK 21 для Gradle,
выберите genericDebug. Machine-local пути, ключи и keystore в Git не добавлять.
Пример local.properties (замените путь своей установленной SDK):

```properties
sdk.dir=C\:/Android/Sdk
```

Сборка и проверка из корня репозитория:

```powershell
powershell -ExecutionPolicy Bypass -File .\branding\build-local.ps1 `
  -JavaHome 'C:\Program Files\Java\jdk-21.0.12' `
  -AndroidSdk "$env:LOCALAPPDATA\Android\Sdk" `
  -OutputDir 'D:\MSHost-Android-Build\dist\domain-20261028' -MavenMirror
Remove-Item Env:\JAVA_TOOL_OPTIONS -ErrorAction SilentlyContinue
.\branding\verify-apk.ps1 -Apk `
  'D:\MSHost-Android-Build\dist\domain-20261028\MSHost-Cloud-Android-35.1.0-Alpha51-debug.apk'
```

Проверяйте код выхода. build-local.ps1 создаёт APK, SHA256SUMS.txt и build-result.json.
verify-apk.ps1 проверяет package/label, min SDK, уникальные authorities и apksigner.
JAVA_TOOL_OPTIONS выводится JVM в stderr; в Windows PowerShell с ErrorActionPreference Stop
это может прервать обёртку проверки, хотя сама сборка уже успешна.
Для сборки при сетевых проблемах использовался -Djava.net.preferIPv4Stack=true.

## Репозитории зависимостей

При сетевых сбоях Maven Central отвечал 403, DNS error и Connection reset.
-MavenMirror включает -PmshostMavenMirror=true; можно задать
mshost.mavenMirror=true в игнорируемом local.properties.
Используется зеркало Maven Central на Google Cloud Storage.
Без опции сохраняется исходный mavenCentral. Порядок pluginManagement не меняется.
PGP/SHA-проверка зависимостей остаётся включённой; verification-metadata.xml не менялся.
Зеркало: https://storage-download.googleapis.com/maven-central/index.html .

## Проверки и безопасное устройство

```powershell
.\gradlew :app:lintGenericDebug :app:spotlessKotlinCheck --max-workers=2
```

-Checks в build-local.ps1 дополнительно запускает SpotBugs/detekt;
не все они сейчас проходят на локальной Windows-машине.
Не отключайте проверки и не обновляйте baseline только для получения зелёного статуса.

Инструментальные тесты запускайте только на отдельном чистом AVD:

```powershell
.\branding\build-local.ps1 -DeviceTests -TestDevice emulator-5582
```

Требуются ровно одно подключённое устройство, имя AVD MSHost_Cloud_Automated,
указанный serial и отсутствие MSHost-аккаунтов. Защита проверяется до Gradle.
Этот AVD автоматически не создаётся и не очищается. Эмулятор для ручного входа
и телефон с настоящими данными для connected-тестов использовать нельзя.
Обычная установка APK — adb install -r, без запуска connectedGenericDebugAndroidTest.
Для установки на собственный телефон можно просто перенести и открыть APK.

Не публикуйте debug.keystore; для production подготовьте отдельный сохраняемый ключ.
