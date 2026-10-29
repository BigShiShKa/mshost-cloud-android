<!--
SPDX-FileCopyrightText: 2026 MSHost contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->
# Проверки и сборки Android

Результаты локальные, 27–28 октября 2026. Текущий APK — genericDebug,
35.1.0 Alpha51 / 350010050; minimum API 28, target 36, compile 37.
ABI: arm64-v8a, armeabi-v7a, x86, x86_64.

| Проверка | Наблюдавшийся результат |
| --- | --- |
| assembleGenericDebug с новым доменом | Успех |
| Имя пакета/название/min SDK | Проверены в реальном APK |
| Уникальные content-provider authorities | Проверены после разрешения resource IDs |
| APK signature | v2, Android Debug, проверена криптографически |
| suggested_server / provider_registration_server | Оба https://cloud.mshostcloud.org в ресурсах APK |
| spotlessKotlinCheck | Прошёл |
| lintGenericDebug | Не прошёл: 5 IconLauncherShape |
| spotbugsGplayDebug | Не прошёл запуск Java-анализатора на Windows |
| detekt | Замечание LargeClass к существующему upstream-классу |
| MshostBrandingIT | 3/3 прошли до смены домена; на пользовательском устройстве повторно не запускались |
| Вход после браузера на телефоне | Успешный результат ещё не зафиксирован |

## Артефакт с новым доменом

Локальная папка D:\MSHost-Android-Build\dist\domain-20261028.
APK и debug keystore не входят в Git; production-подписи/публикации в магазине нет.
Артефакт собран на базе c248c3132083d69907aacebb63ade2666bc7a7c7 с локальными
изменениями до их коммита. Это не заявление о сборке из последующего чистого commit.

```text
37edd1c766f51d28e5878ebc83136bc2e61f4afa641c3f44e47c9f7c332f7c27  MSHost-Cloud-Android-35.1.0-Alpha51-debug.apk
```

SHA-256 публичного сертификата debug-подписи:
`9ff0838d49ca622ce9f1194a42d9c806bb7f97c335fbf318a6a27e62408f100d`.
Это fingerprint сертификата, не приватный ключ.
Старый phone-test APK в корне локального dist содержит прежний default;
актуальный файл находится в подпапке domain-20261028.
