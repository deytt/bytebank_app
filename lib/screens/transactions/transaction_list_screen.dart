import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
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
    _searchController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialTransactions();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialTransactions() {
    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    if (authProvider.user != null) {
      transactionProvider.loadTransactions(authProvider.user!.id, refresh: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<TransactionProvider>().loadMoreTransactions();
    }
  }

  void _applyFilters() {
    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final user = authProvider.user;

    if (user != null) {
      final searchText = _searchController.text.trim();
      final searchTitle = (searchText.isEmpty || searchText.length < 3) ? null : searchText;

      transactionProvider.loadTransactions(
        user.id,
        category: _selectedCategory,
        searchTitle: searchTitle,
        hasReceipt: _hasReceipt,
        dateRangeDays: _selectedDateRange,
        type: _selectedType,
        refresh: true,
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _hasReceipt = null;
      _selectedDateRange = null;
      _selectedType = null;
      _searchController.clear();
    });
    context.read<TransactionProvider>().clearFilters();
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
        _hasReceipt != null ||
        _selectedDateRange != null ||
        _selectedType != null ||
        _searchController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilterDialog()),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialTransactions();
        },
        child: Column(
          children: [
            // Campo de busca
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  helperText: _searchController.text.isNotEmpty && _searchController.text.length < 3
                      ? 'Digite pelo menos 3 caracteres'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.isEmpty || value.length >= 3) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _applyFilters();
                      }
                    });
                  }
                },
              ),
            ),

            if (_hasActiveFilters)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_selectedCategory != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(_selectedCategory!),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    if (_hasReceipt != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(_hasReceipt! ? 'Com recibo' : 'Sem recibo'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _hasReceipt = null;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    if (_selectedDateRange != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text('Últimos $_selectedDateRange dias'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedDateRange = null;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    if (_selectedType != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(
                            _selectedType == TransactionType.income ? 'Receita' : 'Despesa',
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedType = null;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    if (_searchController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text('Busca: "${_searchController.text}"'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        ),
                      ),
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Limpar tudo'),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: transactionProvider.isLoading && transactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 64, color: AppTheme.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma transação encontrada',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: transactions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == transactions.length) {
                          if (transactionProvider.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (!transactionProvider.hasMore) {
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
                                builder: (_) => TransactionFormScreen(transaction: transaction),
                              ),
                            );
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar exclusão'),
                                content: const Text('Deseja realmente excluir esta transação?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text(
                                      'Excluir',
                                      style: TextStyle(color: AppTheme.error),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              final messenger = ScaffoldMessenger.of(context);
                              final success = await transactionProvider.deleteTransaction(
                                transaction,
                              );

                              if (success) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Transação excluída com sucesso'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      transactionProvider.errorMessage ??
                                          'Erro ao excluir transação',
                                    ),
                                    backgroundColor: AppTheme.error,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionFormScreen()));
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
    );
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
                      onSelected: (selected) {
                        setDialogState(() {
                          tempCategory = null;
                        });
                      },
                    ),
                    ..._categories.map(
                      (category) => ChoiceChip(
                        label: Text(category),
                        selected: tempCategory == category,
                        onSelected: (selected) {
                          setDialogState(() {
                            tempCategory = selected ? category : null;
                          });
                        },
                      ),
                    ),
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
                      onSelected: (selected) {
                        setDialogState(() {
                          tempHasReceipt = null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Com recibo'),
                      selected: tempHasReceipt == true,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempHasReceipt = selected ? true : null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Sem recibo'),
                      selected: tempHasReceipt == false,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempHasReceipt = selected ? false : null;
                        });
                      },
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
                      onSelected: (selected) {
                        setDialogState(() {
                          tempDateRange = null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Últimos 15 dias'),
                      selected: tempDateRange == 15,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempDateRange = selected ? 15 : null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Últimos 30 dias'),
                      selected: tempDateRange == 30,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempDateRange = selected ? 30 : null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Últimos 90 dias'),
                      selected: tempDateRange == 90,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempDateRange = selected ? 90 : null;
                        });
                      },
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
                      onSelected: (selected) {
                        setDialogState(() {
                          tempType = null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Receita'),
                      selected: tempType == TransactionType.income,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempType = selected ? TransactionType.income : null;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Despesa'),
                      selected: tempType == TransactionType.expense,
                      onSelected: (selected) {
                        setDialogState(() {
                          tempType = selected ? TransactionType.expense : null;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
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
