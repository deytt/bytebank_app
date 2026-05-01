import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../../models/transaction_model.dart';
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
          appBar: AppBar(title: Text(isEdit ? 'Editar Transação' : 'Nova Transação')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  Text('Tipo', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Despesa'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Receita'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _type = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Data'),
                    subtitle: Text(Formatters.formatDate(_date)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  Text('Recibo (opcional)', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
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
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.receipt, color: AppTheme.textSecondary),
                            SizedBox(width: 8),
                            Text('Recibo já cadastrado'),
                          ],
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Adicionar Recibo'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
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
          return Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onRemove,
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                ),
              ),
            ],
          );
        }
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
