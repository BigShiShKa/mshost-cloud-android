<!--
SPDX-FileCopyrightText: 2026 MSHost contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->
# MSHost Cloud Android

Брендируется вариант **generic**. Локальный APK: **35.1.0 Alpha51**,
versionCode 350010050, Android 9+; applicationId io.github.bigshishka.mshostcloud.
Другие upstream-flavors сохранены для разработки и не считаются брендированными релизами.

Сохранён привычный интерфейс. Для generic заданы свои account type, authorities,
имена БД/данных и редактируемый default https://cloud.mshostcloud.org.
Help/source/download направлены в этот форк. Поиск провайдера, upstream-реклама,
участие и прямые upstream-dev загрузки отключены. Юридические уведомления сохранены.

Логотип branding/icon2-clear.png используется в launcher, adaptive/themed иконках,
splash и шапке. Уведомления используют белую alpha-маску. Генератор assets —
branding/prepare-assets.ps1; лицензии ресурсов указаны в REUSE.toml.

GenerateMshostBrandingResources создаёт брендовые строки 58 локализаций через
Android Variant API. Исходные переводы upstream не редактируются.
Классы Java/Kotlin и протокольные namespaces не переименованы.

## Текущее состояние

APK собран, криптографическая подпись и реальные ресурсы проверены.
Это debug-подпись, не production-релиз. Клиентские сборки с новым доменом
не исправляют автоматически старые аккаунты или проблему входа.

Открыто: на эмуляторе после авторизации в браузере наблюдалось ожидание завершения
входа. Проверка нового APK на телефоне ещё не зафиксирована как успешная.
Generic не использует Firebase-конфигурацию upstream; push требует своей настройки.
Собственная privacy policy не задана, ссылка на чужую политику скрыта.

Полный набор статических проверок не зелёный. Подробнее:
[сборка](docs/mshost/build.md), [проверки](docs/mshost/verification.md),
[история и инцидент тестового удаления](docs/mshost/history.md).
