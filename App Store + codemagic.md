# iOS: від коду до TestFlight — повний гайд

Цей документ описує весь процес публікації iOS-додатку через Codemagic CI
на App Store Connect / TestFlight. Написано на основі реальних помилок,
щоб наступні проєкти проходили з першого разу.

---

## Архітектура збірки

```
Локальний код (GitHub)
        │
        ▼
   Codemagic CI
        │
        ├── 1. brew install xcodegen
        ├── 2. xcodegen generate          ← project.yml → .xcodeproj
        ├── 3. Code signing               ← API Key + CERTIFICATE_PRIVATE_KEY
        ├── 4. xcode-project build-ipa    ← archive + export
        │
        ▼
App Store Connect
        │
        ▼
 TestFlight на iPhone
```

Проєкт використовує **XcodeGen** — `.xcodeproj` в репо немає,
він генерується на CI з `project.yml`. Нові `.swift` файли
підхоплюються автоматично по папці.

---

## Передумови (один раз на акаунт)

### 1. Apple Developer Program

Платна підписка ($99/рік). Без неї App Store Connect недоступний.
Team ID знаходиться на https://developer.apple.com/account → Membership details.

### 2. App Store Connect API Key

Один ключ працює для ВСІХ додатків під одним Team ID.

1. https://appstoreconnect.apple.com → **Users and Access** → **Integrations** → **App Store Connect API** → **Team Keys**
2. **Generate API Key** → Name: `Codemagic`, Role: **App Manager**
3. Скачати `.p8` файл — **завантажується лише один раз!**
4. Записати **Issuer ID** та **Key ID** (показані на тій самій сторінці)

### 3. CERTIFICATE_PRIVATE_KEY

RSA-ключ, яким Codemagic створює Distribution-сертифікат в Apple Developer Portal.
Один ключ для всіх додатків.

```bash
ssh-keygen -t rsa -b 2048 -m PEM -f ios_distribution_private_key -q -N ""
```

Створюються два файли:
- `ios_distribution_private_key` — приватний ключ (ЦЬОГО потрібен вміст)
- `ios_distribution_private_key.pub` — публічний (не потрібен)

Вміст приватного ключа (від `-----BEGIN RSA PRIVATE KEY-----`
до `-----END RSA PRIVATE KEY-----` включно) зберігається в Codemagic.

### 4. Codemagic — початкове налаштування

1. https://codemagic.io → увійти через GitHub
2. **Settings** → **Integrations** → **App Store Connect** → додати інтеграцію:
   - Name: **`Codemagic`** (саме так — це ім'я вказане в `codemagic.yaml`)
   - Issuer ID, Key ID, .p8 файл
3. **Teams** → **Environment variables** → створити групу **`signing`**:
   - Variable name: `CERTIFICATE_PRIVATE_KEY`
   - Variable value: вміст приватного RSA-ключа
   - Secret: увімкнено

> **Ці 4 кроки робляться один раз.** Для кожного нового додатку
> потрібно лише зареєструвати App ID та створити App у ASC (див. нижче).

---

## Для кожного нового проєкту

### Крок 1. Зареєструвати App ID

https://developer.apple.com/account/resources/identifiers/add/appId/bundle

- Platform: iOS
- Description: назва додатку
- Bundle ID: **Explicit**, ввести bundle ID (напр. `morty.diia`)
- Capabilities: увімкнути тільки те, що реально використовується
  (Sign in with Apple, Push Notifications, тощо)

**ВАЖЛИВО:** якщо в App ID увімкнена capability (напр. Sign in with Apple),
то в проєкті ОБОВ'ЯЗКОВО має бути відповідний entitlements файл.
Інакше профіль не зматчиться з таргетом і збірка впаде.
Якщо capability не потрібна — не вмикай її.

### Крок 2. Створити App в App Store Connect

https://appstoreconnect.apple.com → **Apps** → **+** → **New App**

- Platform: iOS
- Name: назва додатку
- Bundle ID: обрати зі списку (зареєстрований на кроці 1)
- SKU: будь-який унікальний рядок (напр. `morty-diia`)
- Primary Language: обрати мову

### Крок 3. Файли проєкту

Обов'язкові файли в корені репозиторію:

#### `project.yml` (XcodeGen)

```yaml
name: MyApp                          # ← ім'я Xcode проєкту

options:
  bundleIdPrefix: com.example        # ← префікс (може бути будь-яким)
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "26"

targets:
  MyApp:                              # ← ім'я таргету = ім'я проєкту
    type: application
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - path: MyApp                   # ← папка з кодом
    info:
      path: Support/Info.plist
      properties:
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
    settings:
      base:
        SWIFT_VERSION: 5.9
        PRODUCT_BUNDLE_IDENTIFIER: com.example.myapp    # ← bundle ID
        DEVELOPMENT_TEAM: WCVNUUU75L                    # ← Team ID
        CODE_SIGN_STYLE: Manual
        TARGETED_DEVICE_FAMILY: "1"                     # 1 = iPhone only
        MARKETING_VERSION: 1.0.0
        CURRENT_PROJECT_VERSION: 1
        GENERATE_INFOPLIST_FILE: YES
        INFOPLIST_KEY_UIApplicationSceneManifest_Generation: YES
        INFOPLIST_KEY_CFBundleDisplayName: MyApp         # ← назва на екрані
        INFOPLIST_KEY_CFBundleIconName: AppIcon           # ← ОБОВ'ЯЗКОВО
        INFOPLIST_KEY_UILaunchScreen_Generation: YES
        INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents: YES
        INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO  # ← без цього TestFlight висить
```

Ключові поля, які треба змінити під новий проєкт:
- `name` / target name / source path
- `PRODUCT_BUNDLE_IDENTIFIER`
- `INFOPLIST_KEY_CFBundleDisplayName`

#### `codemagic.yaml`

```yaml
definitions:
  scripts:
    - &install_xcodegen
      name: Install XcodeGen
      script: brew install xcodegen

    - &generate_project
      name: Generate Xcode project
      script: xcodegen generate

    - &code_signing
      name: Set up code signing
      script: |
        keychain initialize
        app-store-connect fetch-signing-files "BUNDLE_ID_ТУТ" \
          --type IOS_APP_STORE \
          --strict-match-identifier \
          --create
        keychain add-certificates
        xcode-project use-profiles \
          --project PROJECT_NAME.xcodeproj \
          --code-signing-setup-verbose-logging

    - &build_ipa
      name: Build IPA
      script: |
        xcode-project build-ipa \
          --project PROJECT_NAME.xcodeproj \
          --scheme PROJECT_NAME \
          --config Release \
          --archive-xcargs "ONLY_ACTIVE_ARCH=NO SWIFT_STRICT_CONCURRENCY=minimal CURRENT_PROJECT_VERSION=$PROJECT_BUILD_NUMBER"

  environment: &base_environment
    groups:
      - signing
    xcode: "26.0"

workflows:
  ios-testflight:
    name: Build & Upload to TestFlight
    max_build_duration: 60
    instance_type: mac_mini_m1
    integrations:
      app_store_connect: Codemagic
    environment: *base_environment
    scripts:
      - *install_xcodegen
      - *generate_project
      - *code_signing
      - *build_ipa
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: true        # зовнішнє тестування (бета-ревʼю)

  ios-internal:
    name: Build & Upload (internal only)
    max_build_duration: 60
    instance_type: mac_mini_m1
    integrations:
      app_store_connect: Codemagic
    environment: *base_environment
    scripts:
      - *install_xcodegen
      - *generate_project
      - *code_signing
      - *build_ipa
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: false       # тільки внутрішнє тестування
```

Що змінити під новий проєкт (3 місця):
1. `fetch-signing-files "BUNDLE_ID_ТУТ"` — bundle ID
2. `--project PROJECT_NAME.xcodeproj` — ім'я проєкту (з project.yml `name:`)
3. `--scheme PROJECT_NAME` — те саме ім'я

#### `.gitignore`

```
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
*.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist
*.xcworkspace/xcshareddata/swiftpm/
DerivedData/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM
build/
.build/
.swiftpm/
Pods/
Podfile.lock
.DS_Store
*.swp
CLAUDE.md
.claude/
```

#### AppIcon (ОБОВ'ЯЗКОВО)

App Store Connect відхиляє білд без іконки.
Потрібна папка `Resources/Assets.xcassets/AppIcon.appiconset/` з:
- PNG-іконками всіх потрібних розмірів (120, 180, 1024, тощо)
- `Contents.json` що описує кожен розмір

Мінімум — `appstore.png` (1024×1024) для ios-marketing.
Сучасний Xcode (15+) може генерувати решту розмірів з однієї 1024×1024 іконки,
якщо в Contents.json використовувати формат "single size":

```json
{
  "images" : [{ "filename" : "appstore.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" }],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

Також потрібен кореневий `Assets.xcassets/Contents.json`:

```json
{ "info" : { "author" : "xcode", "version" : 1 } }
```

### Крок 4. Підключити репозиторій до Codemagic

1. https://codemagic.io → **Applications** → **Add application**
2. Обрати GitHub-репозиторій
3. Запустити **ios-internal** workflow, branch: **main**

### Крок 5. Встановити на телефон

1. App Store → скачати **TestFlight**
2. App Store Connect → додаток → **TestFlight** → перевірити що Apple ID є в Internal Testing
3. Коли білд оброблений (статус "Ready to Test") — він з'явиться в TestFlight

---

## Два типи тестування

| | ios-internal | ios-testflight |
|---|---|---|
| submit_to_testflight | false | true |
| Хто бачить | Внутрішні тестувальники (до 100) | Зовнішня група (до 10000) |
| Ревʼю Apple | Не потрібно | Потрібно бета-ревʼю |
| Швидкість | Білд доступний через ~10 хв | + час на ревʼю (до 48 год) |
| Коли використовувати | Поточна розробка, швидкий тест | Реліз бета-версії для користувачів |

---

## Помилки, які ми зловили (і як їх уникнути)

### 1. `requires a provisioning profile with the Sign in with Apple feature`

**Причина:** в entitlements файлі або project.yml вказана capability
(Sign in with Apple), але App ID в Developer Portal її не має,
або навпаки — App ID має capability, а проєкт ні.

**Рішення:** capabilities в App ID повинні точно збігатися з entitlements проєкту.
Якщо capability не потрібна — не вмикай ні в App ID, ні в проєкті.
Якщо capability не використовується — видали entitlements секцію з project.yml повністю.

### 2. `requires a provisioning profile` (без згадки capability)

**Причина:** Codemagic не створив/завантажив provisioning profile.
Зазвичай через відсутність `CERTIFICATE_PRIVATE_KEY`.

**Діагностика:** подивитись лог кроку "Set up code signing":
- `Cannot save Signing Certificates without certificate private key` → немає ключа
- `Did not find any certificates from specified locations` → ключ є, але не валідний
- `Did not find suitable provisioning profile` → профіль не зматчився

**Рішення:**
- Переконатись що `CERTIFICATE_PRIVATE_KEY` додано в групу `signing` в Codemagic
- Переконатись що група `signing` підключена в `codemagic.yaml` (environment → groups)

### 3. `Missing required icon file` / `Missing Info.plist value CFBundleIconName`

**Причина:** немає AppIcon в asset catalog або немає ключа `CFBundleIconName`.

**Рішення:**
- Додати `INFOPLIST_KEY_CFBundleIconName: AppIcon` в project.yml settings
- Створити `Resources/Assets.xcassets/AppIcon.appiconset/` з іконками та Contents.json
- Переконатись що є `Resources/Assets.xcassets/Contents.json` (кореневий)

### 4. `xcode-project use-profiles` не знаходить проєкт

**Причина:** за замовчуванням шукає `**/*.xcodeproj` рекурсивно.
Може зловити чужий xcodeproj або взагалі не знайти.

**Рішення:** завжди явно вказувати проєкт:
```
xcode-project use-profiles --project MyApp.xcodeproj
```

### 5. TestFlight білд висить на "Processing" довше ніж звичайно

**Причина:** відсутній ключ `ITSAppUsesNonExemptEncryption` в Info.plist.
Без нього Apple запитує Export Compliance кожного разу.

**Рішення:** `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO` в project.yml
(якщо додаток використовує тільки HTTPS і стандартний CryptoKit).

---

## Чекліст для нового проєкту

```
[ ] Apple Developer Portal: зареєструвати App ID (bundle ID, capabilities)
[ ] App Store Connect: створити New App (name, bundle ID, SKU)
[ ] project.yml: PRODUCT_BUNDLE_IDENTIFIER, CFBundleDisplayName, CFBundleIconName
[ ] codemagic.yaml: bundle ID, project name, scheme name (3 місця)
[ ] AppIcon: 1024×1024 PNG в Assets.xcassets/AppIcon.appiconset/
[ ] .gitignore: є, xcodeproj userdata виключений
[ ] Codemagic: репозиторій підключено
[ ] Codemagic: інтеграція "Codemagic" з API Key (якщо перший раз)
[ ] Codemagic: група "signing" з CERTIFICATE_PRIVATE_KEY (якщо перший раз)
[ ] Запустити ios-internal workflow
[ ] TestFlight: перевірити internal testers, встановити білд
```
