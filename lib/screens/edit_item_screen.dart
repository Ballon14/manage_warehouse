import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import 'barcode_scanner_screen.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final ItemModel item;
  
  const EditItemScreen({super.key, required this.item});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _reorderLevelController;
  late final TextEditingController _uomController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _skuController = TextEditingController(text: widget.item.sku);
    _barcodeController = TextEditingController(text: widget.item.barcode ?? '');
    _reorderLevelController = TextEditingController(text: widget.item.reorderLevel.toString());
    _uomController = TextEditingController(text: widget.item.uom);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _reorderLevelController.dispose();
    _uomController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final itemService = ref.read(itemServiceProvider);
      final reorderLevel = double.tryParse(_reorderLevelController.text) ?? 0;

      final updatedItem = ItemModel(
        id: widget.item.id,
        sku: _skuController.text.trim(),
        name: _nameController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        reorderLevel: reorderLevel,
        uom: _uomController.text.trim(),
        createdAt: widget.item.createdAt,
      );

      await itemService.updateItem(widget.item.id, updatedItem);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Item Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Masukkan nama item';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Masukkan SKU';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Barcode (optional)',
                  prefixIcon: const Icon(Icons.document_scanner),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reorderLevelController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Reorder Level',
                  prefixIcon: Icon(Icons.warning_amber),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan reorder level';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number < 0) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _uomController,
                decoration: const InputDecoration(
                  labelText: 'Unit of Measure',
                  prefixIcon: Icon(Icons.straighten),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Masukkan unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: const Icon(Icons.save),
                label: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Update Item'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
