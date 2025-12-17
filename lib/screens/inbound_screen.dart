import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/stock_provider.dart';
import '../models/item_model.dart';
import 'barcode_scanner_screen.dart';

class InboundScreen extends ConsumerStatefulWidget {
  const InboundScreen({super.key});

  @override
  ConsumerState<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends ConsumerState<InboundScreen> {
  final _qtyController = TextEditingController();
  final _locationController = TextEditingController();
  ItemModel? _selectedItem;
  bool _isScanning = false;

  @override
  void dispose() {
    _qtyController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    setState(() => _isScanning = true);

    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (barcode != null && barcode.isNotEmpty) {
      try {
        final itemService = ref.read(itemServiceProvider);
        final item = await itemService.getItemByBarcode(barcode) ??
            await itemService.getItemById(barcode);

        if (item != null) {
          setState(() {
            _selectedItem = item;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item not found')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    setState(() => _isScanning = false);
  }

  void _selectItemFromList(List<ItemModel> items) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Item',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(item.name),
                      subtitle: Text('SKU: ${item.sku}'),
                      onTap: () {
                        setState(() => _selectedItem = item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processInbound() async {
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or scan an item first')),
      );
      return;
    }

    final qty = double.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final locationId = _locationController.text.trim();
    if (locationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final stockService = ref.read(stockServiceProvider);
      await stockService.inbound(_selectedItem!.id, qty, locationId, user.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inbound processed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _qtyController.clear();
        _locationController.clear();
        setState(() {
          _selectedItem = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbound'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_box_rounded, size: 32, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tambah Stok',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Pilih item dengan scan atau list',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Item'),
                    ),
                    const SizedBox(height: 12),
                    itemsAsync.when(
                      data: (items) => ElevatedButton.icon(
                        onPressed: () => _selectItemFromList(items),
                        icon: const Icon(Icons.list),
                        label: const Text('Pick from list'),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedItem != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _selectedItem!.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'SKU: ${_selectedItem!.sku}${_selectedItem!.barcode != null ? '\nBarcode: ${_selectedItem!.barcode}' : ''}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _selectedItem = null),
                        ),
                      )
                    else
                      const Text(
                        'Select an item via scan or list.',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location ID',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _processInbound,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
              child: const Text('Process Inbound'),
            ),
          ],
        ),
      ),
    );
  }
}

