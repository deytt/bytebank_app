import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/domain/entities/transaction.dart' show TransactionType;
import '../../widgets/transaction_card.dart';
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

  final List<String> _categories = [
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
      context.read<TransactionBloc>().add(
            LoadTransactions(userId: uid, refresh: true),
          );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is TransactionActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
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
          appBar: AppBar(
            title: const Text('Transações'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _loadInitial(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por título (mín. 3 caracteres)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      helperText: _searchController.text.isNotEmpty &&
                              _searchController.text.length < 3
                          ? 'Digite pelo menos 3 caracteres'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                      if (value.isEmpty || value.length >= 3) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchController.text == value) _applyFilters();
                        });
                      }
                    },
                  ),
                ),
                if (_hasActiveFilters) _buildActiveFiltersRow(),
                Expanded(
                  child: isLoading && transactions.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : transactions.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: transactions.length + 1,
                              itemBuilder: (context, index) {
                                if (index == transactions.length) {
                                  if (isLoadingMore) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  if (!hasMore) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          'Todas as transações foram carregadas',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }

                                final transaction = transactions[index];
                                return TransactionCard(
                                  transaction: transaction,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TransactionFormScreen(
                                          transaction: transaction,
                                        ),
                                      ),
                                    );
                                  },
                                  onDelete: () => _confirmDelete(context, transaction),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
              );
            },
            backgroundColor: AppTheme.primary,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildActiveFiltersRow() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedCategory != null)
            _FilterChip(
              label: _selectedCategory!,
              onDeleted: () {
                setState(() => _selectedCategory = null);
                _applyFilters();
              },
            ),
          if (_hasReceipt != null)
            _FilterChip(
              label: _hasReceipt! ? 'Com recibo' : 'Sem recibo',
              onDeleted: () {
                setState(() => _hasReceipt = null);
                _applyFilters();
              },
            ),
          if (_selectedDateRange != null)
            _FilterChip(
              label: 'Últimos $_selectedDateRange dias',
              onDeleted: () {
                setState(() => _selectedDateRange = null);
                _applyFilters();
              },
            ),
          if (_selectedType != null)
            _FilterChip(
              label: _selectedType == TransactionType.income ? 'Receita' : 'Despesa',
              onDeleted: () {
                setState(() => _selectedType = null);
                _applyFilters();
              },
            ),
          if (_searchController.text.isNotEmpty)
            _FilterChip(
              label: 'Busca: "${_searchController.text}"',
              onDeleted: () {
                _searchController.clear();
                _applyFilters();
              },
            ),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Limpar tudo'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TransactionModel transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<TransactionBloc>().add(
            DeleteTransactionRequested(transaction),
          );
    }
  }

  void _showFilterDialog() {
    String? tempCategory = _selectedCategory;
    bool? tempHasReceipt = _hasReceipt;
    int? tempDateRange = _selectedDateRange;
    TransactionType? tempType = _selectedType;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categoria', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: tempCategory == null,
                      onSelected: (_) => setDialogState(() => tempCategory = null),
                    ),
                    ..._categories.map((category) => ChoiceChip(
                          label: Text(category),
                          selected: tempCategory == category,
                          onSelected: (selected) => setDialogState(
                            () => tempCategory = selected ? category : null,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Recibo', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: tempHasReceipt == null,
                      onSelected: (_) => setDialogState(() => tempHasReceipt = null),
                    ),
                    ChoiceChip(
                      label: const Text('Com recibo'),
                      selected: tempHasReceipt == true,
                      onSelected: (s) =>
                          setDialogState(() => tempHasReceipt = s ? true : null),
                    ),
                    ChoiceChip(
                      label: const Text('Sem recibo'),
                      selected: tempHasReceipt == false,
                      onSelected: (s) =>
                          setDialogState(() => tempHasReceipt = s ? false : null),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Período', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: tempDateRange == null,
                      onSelected: (_) => setDialogState(() => tempDateRange = null),
                    ),
                    ChoiceChip(
                      label: const Text('Últimos 15 dias'),
                      selected: tempDateRange == 15,
                      onSelected: (s) =>
                          setDialogState(() => tempDateRange = s ? 15 : null),
                    ),
                    ChoiceChip(
                      label: const Text('Últimos 30 dias'),
                      selected: tempDateRange == 30,
                      onSelected: (s) =>
                          setDialogState(() => tempDateRange = s ? 30 : null),
                    ),
                    ChoiceChip(
                      label: const Text('Últimos 90 dias'),
                      selected: tempDateRange == 90,
                      onSelected: (s) =>
                          setDialogState(() => tempDateRange = s ? 90 : null),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Tipo', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: tempType == null,
                      onSelected: (_) => setDialogState(() => tempType = null),
                    ),
                    ChoiceChip(
                      label: const Text('Receita'),
                      selected: tempType == TransactionType.income,
                      onSelected: (s) => setDialogState(
                        () => tempType = s ? TransactionType.income : null,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Despesa'),
                      selected: tempType == TransactionType.expense,
                      onSelected: (s) => setDialogState(
                        () => tempType = s ? TransactionType.expense : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.white)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = tempCategory;
                _hasReceipt = tempHasReceipt;
                _selectedDateRange = tempDateRange;
                _selectedType = tempType;
              });
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDeleted,
      ),
    );
  }
}
