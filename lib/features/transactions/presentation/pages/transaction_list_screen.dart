import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/transaction.dart' show TransactionType;
import '../bloc/transaction_bloc.dart';
import '../widgets/transaction_filters_dialog.dart';
import '../widgets/transaction_list_body.dart';
import '../widgets/transaction_search_bar.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  bool? _hasReceipt;
  int? _selectedDateRange;
  TransactionType? _selectedType;

  static const List<String> _categories = [
    'Alimentação',
    'Transporte',
    'Saúde',
    'Educação',
    'Lazer',
    'Salário',
    'Investimento',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String? get _userId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.id : null;
  }

  void _loadInitial() {
    final uid = _userId;
    if (uid != null) {
      context.read<TransactionBloc>().add(LoadTransactions(userId: uid, refresh: true));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<TransactionBloc>().add(const LoadMoreTransactions());
    }
  }

  void _applyFilters() {
    final uid = _userId;
    if (uid == null) return;

    final searchText = _searchController.text.trim();
    final searchTitle = (searchText.isEmpty || searchText.length < 3) ? null : searchText;

    context.read<TransactionBloc>().add(
      LoadTransactions(
        userId: uid,
        category: _selectedCategory,
        searchTitle: searchTitle,
        hasReceipt: _hasReceipt,
        dateRangeDays: _selectedDateRange,
        type: _selectedType,
        refresh: true,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _hasReceipt = null;
      _selectedDateRange = null;
      _selectedType = null;
      _searchController.clear();
    });
    context.read<TransactionBloc>().add(const ClearTransactionFilters());
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _hasReceipt != null ||
      _selectedDateRange != null ||
      _selectedType != null ||
      _searchController.text.isNotEmpty;

  Future<void> _showFilterDialog() async {
    final result = await showTransactionFiltersDialog(
      context,
      current: TransactionFilters(
        category: _selectedCategory,
        hasReceipt: _hasReceipt,
        dateRange: _selectedDateRange,
        type: _selectedType,
      ),
      categories: _categories,
    );
    if (result == null || !mounted) return;
    setState(() {
      _selectedCategory = result.category;
      _hasReceipt = result.hasReceipt;
      _selectedDateRange = result.dateRange;
      _selectedType = result.type;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), duration: const Duration(seconds: 2)),
          );
        } else if (state is TransactionActionFailure) {
          final te = AppTheme.of(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: te.error));
        }
      },
      builder: (context, state) {
        final t = AppTheme.of(context);
        final loaded = state is TransactionLoaded
            ? state
            : state is TransactionActionSuccess
            ? state.data
            : state is TransactionActionFailure
            ? state.data
            : null;

        final transactions = loaded?.transactions ?? [];
        final isLoading = state is TransactionLoading;
        final isLoadingMore = loaded?.isLoadingMore ?? false;
        final hasMore = loaded?.hasMore ?? false;

        return Scaffold(
          backgroundColor: t.background,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(gradient: t.transactionAppBarGradient),
            ),
            foregroundColor: t.textPrimary,
            title: const Text('Transações'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: t.transactionScreenBackgroundGradient),
            child: RefreshIndicator(
              color: t.primaryLight,
              onRefresh: () async => _clearFilters(),
              child: Column(
                children: [
                  TransactionSearchBar(
                    controller: _searchController,
                    onSearch: _applyFilters,
                  ),
                  if (_hasActiveFilters) _buildActiveFiltersRow(),
                  Expanded(
                    child: TransactionListBody(
                      transactions: transactions,
                      isLoading: isLoading,
                      isLoadingMore: isLoadingMore,
                      hasMore: hasMore,
                      scrollController: _scrollController,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
              );
            },
            backgroundColor: t.primary,
            foregroundColor: t.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nova Transação'),
          ),
        );
      },
    );
  }

  Widget _buildActiveFiltersRow() {
    final t = AppTheme.of(context);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (_selectedCategory != null)
            TransactionFilterChip(
              label: _selectedCategory!,
              onDeleted: () {
                setState(() => _selectedCategory = null);
                _applyFilters();
              },
            ),
          if (_hasReceipt != null)
            TransactionFilterChip(
              label: _hasReceipt! ? 'Com recibo' : 'Sem recibo',
              onDeleted: () {
                setState(() => _hasReceipt = null);
                _applyFilters();
              },
            ),
          if (_selectedDateRange != null)
            TransactionFilterChip(
              label: 'Últimos $_selectedDateRange dias',
              onDeleted: () {
                setState(() => _selectedDateRange = null);
                _applyFilters();
              },
            ),
          if (_selectedType != null)
            TransactionFilterChip(
              label: _selectedType == TransactionType.income ? 'Receita' : 'Despesa',
              onDeleted: () {
                setState(() => _selectedType = null);
                _applyFilters();
              },
            ),
          if (_searchController.text.isNotEmpty)
            TransactionFilterChip(
              label: 'Busca: "${_searchController.text}"',
              onDeleted: () {
                _searchController.clear();
                _applyFilters();
              },
            ),
          TextButton.icon(
            onPressed: _clearFilters,
            style: TextButton.styleFrom(foregroundColor: t.actionForeground),
            icon: const Icon(Icons.clear_all_rounded, size: 18),
            label: const Text('Limpar tudo'),
          ),
        ],
      ),
    );
  }
}
