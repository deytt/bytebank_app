import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
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
      _valueController.text = widget.transaction!.value.toString();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    if (authProvider.user == null) return;

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      userId: authProvider.user!.id,
      title: _titleController.text.trim(),
      value: double.parse(_valueController.text),
      category: _category,
      type: _type,
      date: _date,
      receiptUrl: widget.transaction?.receiptUrl,
    );

    bool success;
    if (widget.transaction == null) {
      success = await transactionProvider.addTransaction(transaction, receiptFile: _receiptFile);
    } else {
      success = await transactionProvider.updateTransaction(transaction, receiptFile: _receiptFile);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction == null ? 'Transação adicionada' : 'Transação atualizada',
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(transactionProvider.errorMessage ?? 'Erro ao salvar transação'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final isEdit = widget.transaction != null;

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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                label: 'Valor',
                controller: _valueController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Valor é obrigatório';
                  }
                  final numValue = double.tryParse(value);
                  if (numValue == null || numValue <= 0) {
                    return 'Valor deve ser maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Tipo', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
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
                onSelectionChanged: (Set<TransactionType> newSelection) {
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
                subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              const Text(
                'Recibo (opcional)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
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
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: transactionProvider.isLoading ? null : _submit,
                  child: transactionProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white),
                        )
                      : Text(isEdit ? 'Atualizar' : 'Adicionar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget helper para preview de recibo que funciona em todas as plataformas
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
                  image: DecorationImage(image: MemoryImage(snapshot.data!), fit: BoxFit.cover),
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
        return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
