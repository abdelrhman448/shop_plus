# Task 4 — Code Review & Performance

For each snippet below: **the problem**, **why it matters**, and **the fix**.

---

## Snippet 1 — API Service

### Problems
1. **No error body / status handling on `transferPoints`.** The response is
   awaited but never checked, so a `4xx`/`5xx` is silently swallowed and the UI
   thinks the transfer succeeded.
2. **Weak error type.** `throw Exception('Failed to load')` loses the status
   code and server message, so the UI can't show a meaningful, localized error.
3. **Untyped `Map<String, dynamic>` returned.** Parsing leaks into the caller;
   there is no model boundary and no `Content-Type: application/json` header.
4. **No timeout.** A hung request blocks forever.

### Why it matters
Financial operations must fail loudly and specifically. Silent failures on a
transfer are a correctness and trust problem; untyped maps push fragile parsing
into every caller.

### Fix
```dart
class WalletService {
  WalletService(this.client, {this.baseUrl = 'https://api.shopplus.com'});

  final http.Client client;
  final String baseUrl;

  static const _timeout = Duration(seconds: 15);

  Future<PointsBalance> getBalance() async {
    final response = await client
        .get(
          Uri.parse('$baseUrl/wallet/balance'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw WalletException('NETWORK', 'Failed to load balance '
          '(${response.statusCode})');
    }
    return PointsBalance.fromJson(
      json.decode(response.body) as Map<String, dynamic>,
    );
  }

  Future<TransferResult> transferPoints(TransferRequest request) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/wallet/transfer'),
          headers: const {'Content-Type': 'application/json'},
          body: json.encode(request.toJson()),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return TransferResult.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    // Map the server's error code to a typed, user-facing exception.
    final body = json.decode(response.body) as Map<String, dynamic>;
    throw WalletException(
      body['code'] as String? ?? 'NETWORK',
      body['message'] as String? ?? 'Transfer failed',
    );
  }
}
```

---

## Snippet 2 — Widget

### Problems
1. **No `dispose`/`mounted` guard.** `setState` can be called after the widget
   is unmounted (async `loadData` completing after navigation) → exception.
2. **No error or empty handling.** Only loading and success are represented.
3. **Business/data logic lives in the widget** (`WalletApi()` constructed
   inline) — untestable and violates separation of concerns.
4. **`CircularProgressIndicator` is not centered.**
5. **Non-`const`, manual `Container` styling** rebuilt for every row instead of
   a reusable, `const`-friendly tile.

### Why it matters
Calling `setState` after dispose is a common production crash. Building the data
layer inside the widget makes the screen impossible to unit-test and couples UI
to networking.

### Fix
Move data access behind a repository and state into a BLoC (as done in this
project), then the widget only renders state:
```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<WalletBloc, WalletState>(
    builder: (context, state) => switch (state) {
      WalletLoading() => const Center(child: CircularProgressIndicator()),
      WalletError(:final message) => ErrorView(message: message, onRetry: ...),
      WalletLoaded(:final transactions) when transactions.isEmpty =>
        const EmptyView(),
      WalletLoaded(:final transactions) => ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (_, i) => TransactionTile(
            key: ValueKey(transactions[i].id),
            transaction: transactions[i],
          ),
        ),
      _ => const SizedBox.shrink(),
    },
  );
}
```
If a `StatefulWidget` must keep local async, guard it:
```dart
final result = await api.getTransactions();
if (!mounted) return;
setState(() { ... });
```

---

## Snippet 3 — Performance Issue

### Problems
1. **`ListView(children: transactions.map(...))`** builds **every** row eagerly,
   even those off-screen. With a long list this is O(n) widgets up-front.
2. **`Image.network`** has no caching → re-downloads/re-decodes logos on every
   rebuild and scroll, and no `cacheWidth`/`cacheHeight` (decodes full-size).
3. **No `errorBuilder`/`loadingBuilder`** → broken image icon or jank on failure.
4. **`DateFormat` created per item** in `build`.

### Why it matters
Eager building + un-cached network images is the classic cause of janky,
memory-hungry lists on both mobile and web.

### Fix
```dart
class TransactionList extends StatelessWidget {
  const TransactionList({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(               // lazy: builds only visible rows
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        return Card(
          key: ValueKey(t.id),             // stable identity across reorders
          child: ListTile(
            leading: CachedNetworkImage(   // memory + disk cache
              imageUrl: t.merchantLogo,
              width: 40,
              height: 40,
              memCacheWidth: 80,           // decode downscaled
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const Icon(Icons.store),
            ),
            title: Text(t.description),
            subtitle: Text(Formatters.shortDate(t.createdAt)),
          ),
        );
      },
    );
  }
}
```

---

## Snippet 4 — State Management

### Problems
1. **Destructive filtering.** `FilterTransactions` replaces the loaded list with
   a filtered subset. Switching back to "All" loses the original data — there is
   no way to recover it without a network round-trip.
2. **No error handling.** If `getBalance`/`getTransactions` throws, the bloc
   never emits an error state and the UI hangs on loading forever.
3. **Sequential awaits** for two independent calls (minor; can be parallelized).

### Why it matters
The destructive filter is a real functional bug: the "All" chip would show an
incomplete list after any filter. Missing error handling means no retry path.

### Fix
Keep the master list intact and derive the filtered view (exactly how
`WalletLoaded` works in this project), and wrap loads in try/catch:
```dart
on<LoadWallet>((event, emit) async {
  emit(const WalletLoading());
  try {
    final results = await Future.wait([        // parallel, independent calls
      repository.getBalance(),
      repository.getTransactions(),
    ]);
    emit(WalletLoaded(
      balance: results[0] as PointsBalance,
      transactions: (results[1] as PaginatedTransactions).transactions,
    ));
  } on WalletException catch (e) {
    emit(WalletError(code: e.code, message: e.message));
  }
});

on<FilterTransactions>((event, emit) {
  final s = state;
  if (s is WalletLoaded) {
    emit(s.copyWith(activeFilter: event.type)); // master list untouched
  }
});
```
Where `WalletLoaded.visibleTransactions` applies `activeFilter` on top of the
preserved `transactions` list.

---

## Snippet 5 — Performance Question

**Five techniques for a large, image-heavy transaction list:**

1. **Lazy building with `ListView.builder` / `SliverList`.**
   *When:* any list that can grow beyond a screen.
   *Why:* only visible (plus a small cache-extent) rows are built, keeping the
   widget count and build time bounded regardless of list length.

2. **Image caching + right-sizing (`CachedNetworkImage`, `cacheWidth`).**
   *When:* rows show remote images (merchant logos/avatars).
   *Why:* avoids re-downloading and re-decoding on every scroll/rebuild, and
   decoding to display size slashes memory (a 40px avatar shouldn't decode a
   1000px bitmap).

3. **`const` constructors + granular widgets.**
   *When:* everywhere possible; split big `build` methods into small widgets.
   *Why:* `const` widgets are canonicalized and skipped during rebuilds, and
   small widgets localize rebuilds so a state change repaints only what changed.

4. **Efficient state management / scoped rebuilds** (BLoC `buildWhen`,
   `context.select`, `RepaintBoundary` for heavy items).
   *When:* frequent state updates (pagination, filtering, live balance).
   *Why:* rebuilding the whole tree on every emit is the most common cause of
   jank; rebuild only the widgets whose data actually changed.

5. **Pagination / lazy loading with stable `Key`s and memory management.**
   *When:* server-backed lists of unknown size.
   *Why:* fetching pages on demand keeps memory and network bounded; stable
   `ValueKey`s let Flutter recycle element/state correctly when items shift,
   and disposing controllers/streams prevents leaks.

**Honorable mentions:** debounce scroll-driven pagination triggers, use
`addAutomaticKeepAlives: false` when items needn't preserve state off-screen,
and prefer `SliverList.separated` over inserting divider widgets manually.
