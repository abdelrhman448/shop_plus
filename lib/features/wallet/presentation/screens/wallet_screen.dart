import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/language_toggle_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/models.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_transactions_view.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_error_view.dart';
import '../widgets/wallet_shimmer.dart';

// Main Wallet screen: balance, filters and history. Just reacts to WalletBloc.
// On wide screens we cap the width so it stays usable on web/desktop.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  static const routePath = '/wallet';
  static const routeName = 'wallet';

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load the next page a bit before we hit the bottom.
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<WalletBloc>().add(const LoadMoreTransactions());
    }
  }

  Future<void> _openTransfer(PointsBalance balance) async {
    await context.pushNamed(
      'transfer',
      extra: balance.totalPoints,
    );
    // Coming back from a transfer? Refresh so the new balance shows up.
    if (mounted) {
      context.read<WalletBloc>().add(const RefreshWallet());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walletTitle),
        actions: const [LanguageToggleButton()],
      ),
      body: SafeArea(
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            return switch (state) {
              WalletInitial() || WalletLoading() => const WalletShimmer(),
              WalletError(:final code, :final message) => WalletErrorView(
                  code: code,
                  fallbackMessage: message,
                  onRetry: () =>
                      context.read<WalletBloc>().add(const LoadWallet()),
                ),
              WalletLoaded() => _LoadedView(
                  state: state,
                  scrollController: _scrollController,
                  onTransfer: () => _openTransfer(state.balance),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.state,
    required this.scrollController,
    required this.onTransfer,
  });

  final WalletLoaded state;
  final ScrollController scrollController;
  final VoidCallback onTransfer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visible = state.visibleTransactions;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WalletBloc>().add(const RefreshWallet());
        // Keep the spinner until the bloc finishes reloading.
        await context
            .read<WalletBloc>()
            .stream
            .firstWhere((s) => s is WalletLoaded || s is WalletError);
      },
      child: CenteredContent(
        child: CustomScrollView(
          controller: scrollController,
          // Always scrollable so pull-to-refresh works even with a short list.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: BalanceCard(balance: state.balance),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: FilledButton.icon(
                  onPressed: onTransfer,
                  icon: const Icon(Icons.send),
                  label: Text(l10n.transferPoints),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Text(
                  l10n.transactions,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: TransactionFilterBar(
                  selected: state.activeFilter,
                  onSelected: (type) => context
                      .read<WalletBloc>()
                      .add(FilterTransactions(type)),
                ),
              ),
            ),
            if (visible.isEmpty)
              const SliverToBoxAdapter(child: EmptyTransactionsView())
            else
              SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 72, endIndent: 12),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TransactionTile(
                    key: ValueKey(visible[index].id),
                    transaction: visible[index],
                  ),
                ),
              ),
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
