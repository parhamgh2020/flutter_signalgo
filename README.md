# SignalGo

Cross-platform Flutter app for cryptocurrency market analysis, backed entirely by a
**self-hosted Appwrite** instance. Bilingual (English / فارسی) with real RTL layout
mirroring, not just translated strings.

## Stack

- Flutter (null-safety), Riverpod for state management
- Appwrite Dart SDK (Databases, Realtime, Account) — no exchange APIs are called directly
- `fl_chart` for the sparkline/indicator lines; the OHLC candlestick chart itself is a
  hand-rolled `CustomPainter` (fl_chart has no native candlestick series, and its gesture
  model doesn't support combined pinch-zoom + single-finger scrub)
- `flutter_localizations` + ARB files (`lib/l10n/app_en.arb`, `lib/l10n/app_fa.arb`),
  Vazirmatn font (via `google_fonts`) for `fa`, optional Jalali date formatting
- `shared_preferences` for settings, Hive for an offline "last-fetched" cache
- Mock repositories behind every domain repository interface, so the whole UI can
  run fully offline via `USE_MOCK_BACKEND=true` with no backend configured

## Project layout

```
lib/
  core/        appwrite client, theme, router/app shell, localization helpers, errors
  features/
    symbols/   symbols list, search/sort/filter, realtime prices
    chart/     candlestick chart, indicators, analysis card
    news/      news feed, market overview, featured carousel
    watchlist/ per-user watchlist (used by symbols + settings)
    settings/  language/theme/currency, account, about
  l10n/        ARB source files + generated AppLocalizations
```

Each feature follows `data / domain / presentation`. Every repository has a `*Mock`
and a `*Appwrite` implementation behind the same abstract interface
(`lib/features/*/domain/repositories/*.dart`), selected at runtime by
`useMockBackendProvider` (`lib/core/providers/repo_mode_provider.dart`).

## Running

### Against a self-hosted Appwrite instance (default)

```bash
flutter run \
  --dart-define=APPWRITE_ENDPOINT=https://your-appwrite-host/v1 \
  --dart-define=APPWRITE_PROJECT_ID=your-project-id \
  --dart-define=APPWRITE_DATABASE_ID=market_data \
  --dart-define=APPWRITE_SELF_SIGNED=false
```

`USE_MOCK_BACKEND` defaults to `false`, so the app hits the real Appwrite instance
out of the box — make sure the database/collections below exist first.

### Against the mock backend (offline, no setup required)

```bash
flutter pub get
flutter run --dart-define=USE_MOCK_BACKEND=true
```

Runs with realistic seeded data (symbols, candles, analyses, news) and simulated
realtime price ticks — no Appwrite instance needed.

| Variable | Default | Notes |
|---|---|---|
| `USE_MOCK_BACKEND` | `false` | Set `true` to run fully offline against seeded mock data |
| `APPWRITE_ENDPOINT` | `https://localhost/v1` | Your instance's API endpoint |
| `APPWRITE_PROJECT_ID` | `signalgo-dev` | Appwrite project ID |
| `APPWRITE_DATABASE_ID` | `market_data` | Database ID containing the collections below |
| `APPWRITE_SELF_SIGNED` | `false` | Set `true` for a staging host with a self-signed cert (ignored on web) |

Endpoint/project are never hardcoded — see `lib/core/appwrite/appwrite_config.dart`.
For a staging vs. production split, keep two `--dart-define-from-file` JSON files and
select one per run/build.

## Appwrite backend setup

Create a database (matching `APPWRITE_DATABASE_ID`) with the following collections.
Attribute names must match exactly — the data layer reads raw field keys (see each
feature's `data/models/*_model.dart`).

### `symbols`

| Attribute | Type | Notes |
|---|---|---|
| `symbol` | string, required | e.g. `BTC` |
| `name` | string, required | |
| `name_fa` | string | optional |
| `icon_url` | string (url) | optional |
| `price` | double, required | |
| `change_24h` | double, required | percent |
| `change_7d` | double, required | percent |
| `market_cap` | double, required | |
| `volume_24h` | double, required | |
| `rank` | integer, required | |
| `updated_at` | datetime, required | |
| `sparkline` | double[] | optional — powers the list row's mini sparkline; omit to hide it |

Indexes: `key` index on `market_cap` (desc), `change_24h`, `rank`; a **fulltext** index
on `name` (required for `Query.search('name', …)`).

Permissions: read — `any`; write — restricted to a server/API-key integration that
syncs price data (the app never writes to this collection).

### Candles — one collection per symbol/timeframe

Candles are **not** stored in a single shared collection. Each ticker/timeframe pair
gets its own collection, named `{TICKER}USDT_{timeframe}` (ticker from `symbols.symbol`,
uppercased, always quoted in USDT) — e.g. `BTCUSDT_1d`, `BTCUSDT_4h`, `BTCUSDT_1w`.
Create one such collection per symbol you support, per timeframe you serve.

| Attribute | Type | Notes |
|---|---|---|
| `open`, `high`, `low`, `close` | double, required | |
| `volume` | double, required | |
| `timestamp` | datetime, required | |

Indexes: key index on `timestamp` — required for `Query.orderDesc('timestamp')`
pagination (`lib/features/chart/data/repositories/chart_repository_appwrite.dart`).

Permissions: read — `any`; write — server-side only.

### `analyses`

| Attribute | Type | Notes |
|---|---|---|
| `symbol` | string, required | |
| `timeframe` | string, required | |
| `trend` | string, required | `bullish` \| `bearish` \| `sideways` |
| `summary_en` | string, required | |
| `summary_fa` | string | optional, falls back to `summary_en` |
| `support_levels` | double[] | |
| `resistance_levels` | double[] | |
| `indicators` | object (JSON) | `{ "ma": number, "rsi": number, "macd": number }` — latest snapshot values, not a series |
| `signal` | string, required | `buy` \| `sell` \| `neutral` |
| `confidence` | double, required | 0–100 |
| `created_at` | datetime, required | |

Indexes: composite key index on (`symbol`, `timeframe`, `created_at`).

Permissions: read — `any`; write — server-side only.

> The chart's MA overlay line is computed client-side from `candles` (a simple moving
> average needs the full series, which this snapshot-style collection doesn't carry).
> RSI/MACD are shown as their latest snapshot value from `analyses.indicators`.

### `news`

| Attribute | Type | Notes |
|---|---|---|
| `title_en` | string, required | |
| `title_fa` | string | optional |
| `body_en` | string, required | |
| `body_fa` | string | optional |
| `source` | string, required | |
| `image_url` | string (url) | optional |
| `url` | string (url), required | original article link |
| `tags` | string[] | |
| `published_at` | datetime, required | |
| `is_featured` | boolean, required | |

Indexes: key index on `published_at` (desc); key index on `is_featured`; fulltext
index on `title_en`.

Permissions: read — `any`; write — server-side only.

### `watchlist`

| Attribute | Type | Notes |
|---|---|---|
| `user_id` | string, required | Appwrite Auth user ID |
| `symbol` | string, required | the `symbols.$id` (or `symbol` code) being watched |
| `created_at` | datetime, required | |

Indexes: key index on (`user_id`, `symbol`).

Permissions: **document security enabled**, no collection-level read/write. Each
document is created with `Permission.read(Role.user(userId))` and
`Permission.delete(Role.user(userId))` (see
`lib/features/watchlist/data/repositories/watchlist_repository_appwrite.dart`) so a
user can only ever see and remove their own watchlist entries.

### Auth

Enable **Anonymous** sessions (the app opens one automatically on first launch) and
**Email/Password** sessions (for the optional sign-in that syncs the watchlist across
devices). No other providers are required.

### Realtime

No extra configuration beyond the collections above — the app subscribes to
`databases.{databaseId}.collections.{symbols|candles|watchlist}.documents` and
reconnects with exponential backoff, falling back to periodic polling if the socket
stays down (see `SymbolsListController` / `ChartCandlesController`).

### Health check

Settings → About pings your instance's public `/health` endpoint
(`{endpoint}/health`, no auth required) to show an online/offline indicator.

## Tests

```bash
flutter test
```

Covers: mock repositories for symbols/watchlist/news (pagination, sort, search,
realtime-ish updates), the locale-field-picker helper (`LocalizedFieldLocale.pick`),
and a widget test asserting `fa` resolves to RTL / `en` resolves to LTR directionality.

## Localization

- Every user-facing string is in `lib/l10n/app_en.arb` / `lib/l10n/app_fa.arb` — run
  `flutter gen-l10n` (or just `flutter run`, which triggers it) after editing them.
- Backend content fields (`summary_en`/`summary_fa`, `title_en`/`title_fa`, etc.) are
  picked via `context.localizedField(en: ..., fa: ...)`
  (`lib/core/localization/localized_field.dart`), falling back to English when the
  Farsi field is missing.
- Switching language in Settings applies RTL immediately, no restart needed.
