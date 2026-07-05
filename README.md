# ShopPlus Wallet — Flutter Assessment

**Author:** Abdelrhman Mostafa
**Stack:** Flutter 3.38+ · Dart 3.10 · `flutter_bloc` · `go_router`

A commerce & loyalty **Wallet** feature for ShopPlus, running on **iOS,
Android and Web** with a responsive UI. It covers a Wallet screen (balance +
transaction history) and a Transfer Points screen with full form validation.

---

## Quick start

```bash
# 1. Install dependencies
flutter pub get

# 2. (Re)generate localizations if you edit the .arb files
flutter gen-l10n

# 3. Run
flutter run                 # mobile / connected device
flutter run -d chrome       # web

# 4. Analyze & test
flutter analyze
flutter test
```

> This repo uses `fvm` with Flutter `3.38.2`. If you use fvm, prefix commands
> with `fvm` (e.g. `fvm flutter test`).

---

## What's implemented

### Task 2 — Wallet screen
- Immutable, `Equatable`, JSON-serializable models with `copyWith`
  (`PointsBalance`, `MerchantBalance`, `Transaction`, `PaginatedTransactions`,
  `TransferRequest`, `TransferResult`).
- `WalletRepository` interface + `MockWalletRepository` (sample data, simulated
  latency, server-style pagination & filtering, typed errors).
- `WalletBloc`: `initial / loading / loaded / error` states; `LoadWallet`,
  `RefreshWallet`, `FilterTransactions`, `LoadMoreTransactions` events.
- UI: gradient **balance card**, **transaction list** with type icons/colors,
  **filter chips**, **pull-to-refresh**, **shimmer** loading, **error** state
  with retry, and an **empty** state.
- Unit tests for the repository and the BLoC.

### Task 3 — Transfer Points screen
- `go_router` with `/wallet` and nested `/wallet/transfer`.
- Real-time validation: recipient (**Egyptian phone `+20…`** or **email**),
  amount (**100 → available balance**, whole numbers), optional note (**≤150**).
- Submit disabled until valid, loading state, success dialog with the new
  balance, typed error handling (`INSUFFICIENT_BALANCE`, `RECIPIENT_NOT_FOUND`),
  and back-navigation + auto-refresh on success.
- **Sensitive data:** autofill/suggestions/autocorrect disabled on the
  recipient field, inputs cleared and controllers disposed on exit, and no
  sensitive values are logged.

### Task 1 & 4 — Docs
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — structure, state-management
  choice, state-flow diagram, error handling.
- [`docs/CODE_REVIEW.md`](docs/CODE_REVIEW.md) — fixes for all 5 snippets + the
  performance answer.

### Optional / bonus
- **Localization** — English & Arabic with automatic **RTL**; toggle in the
  AppBar (`LocaleCubit`).
- **Responsive** — content constrained to a readable width on tablet/desktop
  (`core/responsive`).
- **Accessibility** — semantic labels on the balance card and transaction rows.
- **Widget tests** — wallet load/filter and transfer validation flows.
- **Reusable package** — [`packages/api_client`](packages/api_client) (see below).

---

## Mock data approach

There is no live API, so `MockWalletRepository` implements the same
`WalletRepository` interface the real client will implement later. It:

- returns the **exact sample data** from the assessment,
- simulates network latency via `Future.delayed` (configurable — tests inject
  `Duration.zero` for speed),
- performs **filtering and pagination in the repository** (like a server would),
  guarding out-of-range pages instead of throwing,
- throws the documented `WalletException`s (`INSUFFICIENT_BALANCE` when
  `points > 15750`, `RECIPIENT_NOT_FOUND` for `notfound@test.com`).

Because the BLoC depends only on the interface, going live means swapping the
implementation in `main.dart` — no UI, state or test changes required.

---

## Key decisions & trade-offs

- **Feature-first + layered** structure: everything about the wallet lives under
  `features/wallet`, split into `data` and `presentation`. Easy to navigate and
  to extract into a module later.
- **BLoC for the screen, Cubit for the form:** the screen has multiple actions
  and benefits from an explicit event contract; the transfer form has a single
  `submit` action, where a Cubit is simpler with no loss of testability.
- **Filtering preserves the master list:** `WalletLoaded` keeps the full list
  and exposes a derived `visibleTransactions`. This fixes the classic bug (see
  Snippet 4) where filtering destroys the original data.
- **Typed errors (`WalletErrorCode`)** instead of raw strings, so the UI can map
  a failure to a localized message in one place.
- **`CachedNetworkImage`** for merchant logos to avoid re-downloads on scroll.

---

## Project layout

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the annotated tree and
diagrams.

## Tests

```bash
flutter test
```
Covers: repository (balance, pagination, filtering, transfer success/errors),
`WalletBloc` (all events + error mapping), `TransferCubit`, `Validators`, and
widget tests for the wallet and transfer screens.
