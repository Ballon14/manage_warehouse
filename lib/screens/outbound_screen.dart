import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/stock_provider.dart';
import '../models/item_model.dart';
import 'barcode_scanner_screen.dart';

class OutboundScreen extends ConsumerStatefulWidget {
  const OutboundScreen({super.key});

  @override
  ConsumerState<OutboundScreen> createState() => _OutboundScreenState();
}

class _OutboundScreenState extends ConsumerState<OutboundScreen> {
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

    // Use BarcodeScannerScreen for consistency with InboundScreen
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

  Future<void> _processOutbound() async {
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
      await stockService.outbound(_selectedItem!.id, qty, locationId, user.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outbound processed successfully'),
            backgroundColor: Colors.orange,
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
        title: const Text('Outbound'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.remove_circle, size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
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
              onPressed: _processOutbound,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
              ),
              child: const Text('Process Outbound'),
            ),
          ], // Closing children array for Column
        ), // Closing Column
      ), // Closing SingleChildScrollView
    ), // Closing ConstrainedBox
  ), // Closing Center (body)
); // Closing Scaffold
  }
}

