import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/domain/entities/transaction.dart' show TransactionType;
import '../../widgets/custom_input.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = 'Alimentação';
  DateTime _date = DateTime.now();
  XFile? _receiptFile;

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
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _valueController.text = Formatters.formatCurrencySimple(widget.transaction!.value);
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _date = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptFile = pickedFile;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      userId: authState.user.id,
      title: _titleController.text.trim(),
      value: Formatters.parseCurrency(_valueController.text),
      category: _category,
      type: _type,
      date: _date,
      receiptUrl: widget.transaction?.receiptUrl,
    );

    if (widget.transaction == null) {
      context.read<TransactionBloc>().add(
            AddTransactionRequested(transaction: transaction, receiptFile: _receiptFile),
          );
    } else {
      context.read<TransactionBloc>().add(
            UpdateTransactionRequested(transaction: transaction, receiptFile: _receiptFile),
          );
    }
  }

  Widget _formSection({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.formSectionDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionActionSuccess) {
          Navigator.pop(context);
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
        final isSubmitting = state is TransactionLoaded && state.isSubmitting;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(gradient: AppTheme.transactionAppBarGradient),
            ),
            foregroundColor: AppTheme.textPrimary,
            title: Text(isEdit ? 'Editar Transação' : 'Nova Transação'),
          ),
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: AppTheme.transactionScreenBackgroundGradient),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
                      fillColor: AppTheme.surface.withValues(alpha: 0.55),
                    ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _formSection(
                        children: [
                          CustomInput(
                            label: 'Título',
                            controller: _titleController,
                            maxLength: 50,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Título é obrigatório';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomInput(
                            label: 'Valor',
                            controller: _valueController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter(maxDigits: 8)],
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Valor é obrigatório';
                              final numValue = Formatters.parseCurrency(value);
                              if (numValue <= 0) return 'Valor deve ser maior que zero';
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _formSection(
                        children: [
                          Text('Tipo', style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 8),
                          SegmentedButton<TransactionType>(
                            segments: const [
                              ButtonSegment(
                                value: TransactionType.expense,
                                label: Text('Despesa'),
                                icon: Icon(Icons.arrow_downward_rounded),
                              ),
                              ButtonSegment(
                                value: TransactionType.income,
                                label: Text('Receita'),
                                icon: Icon(Icons.arrow_upward_rounded),
                              ),
                            ],
                            selected: {_type},
                            onSelectionChanged: (newSelection) {
                              setState(() {
                                _type = newSelection.first;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Categoria'),
                            initialValue: _category,
                            items: _categories.map((category) {
                              return DropdownMenuItem(value: category, child: Text(category));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _category = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _formSection(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _selectDate,
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 20,
                                      color: AppTheme.textSecondary.withValues(alpha: 0.95),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Data',
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            Formatters.formatDate(_date),
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _formSection(
                        children: [
                          Text(
                            'Recibo (opcional)',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 10),
                          if (_receiptFile != null)
                            _ReceiptPreview(
                              receiptFile: _receiptFile!,
                              onRemove: () {
                                setState(() {
                                  _receiptFile = null;
                                });
                              },
                            )
                          else if (widget.transaction?.receiptUrl != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.surface.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.primaryLight.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    color: AppTheme.textSecondary.withValues(alpha: 0.95),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Recibo já cadastrado',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload_file_rounded),
                              label: const Text('Adicionar Recibo'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                foregroundColor: AppTheme.textPrimary,
                                side: BorderSide(color: AppTheme.primaryLight.withValues(alpha: 0.45)),
                                backgroundColor: AppTheme.surface.withValues(alpha: 0.35),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.white,
                                  ),
                                )
                              : Text(isEdit ? 'Atualizar' : 'Adicionar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  final XFile receiptFile;
  final VoidCallback onRemove;

  const _ReceiptPreview({required this.receiptFile, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: receiptFile.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.25)),
                    image: DecorationImage(
                      image: MemoryImage(snapshot.data!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.white),
                    onPressed: onRemove,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.black.withValues(alpha: 0.54),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryLight),
          ),
        );
      },
    );
  }
}
