import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/stock_provider.dart';
import 'barcode_scanner_screen.dart';

class StockOpnameScreen extends ConsumerStatefulWidget {
  const StockOpnameScreen({super.key});

  @override
  ConsumerState<StockOpnameScreen> createState() => _StockOpnameScreenState();
}

class _StockOpnameScreenState extends ConsumerState<StockOpnameScreen> {
  String? _sessionId;
  String? _locationId;
  final _locationController = TextEditingController();
  bool _isSessionActive = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    final locationId = _locationController.text.trim();
    if (locationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location ID')),
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
      final sessionId =
          await stockService.createInventoryCount(user.uid, locationId);

      setState(() {
        _sessionId = sessionId;
        _locationId = locationId;
        _isSessionActive = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock opname session created'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _scanAndCount() async {
    if (!_isSessionActive || _sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a session first')),
      );
      return;
    }

    // Cache context before async gap
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    // Use BarcodeScannerScreen for consistency
    final barcode = await navigator.push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (barcode == null || barcode.isEmpty) return;

    try {
      final itemService = ref.read(itemServiceProvider);
      final item = await itemService.getItemByBarcode(barcode) ??
          await itemService.getItemById(barcode);

      if (item == null) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Item not found')),
          );
        }
        return;
      }

      // Use mounted check and don't use context after async gap
      if (!mounted) return;
      
      final countedQty = await showDialog<double>(
        context: context,
        builder: (builderContext) {
          final qtyController = TextEditingController();
          return AlertDialog(
            title: Text('Count: ${item.name}'),
            content: TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Counted Quantity',
              ),
              onSubmitted: (value) {
                final qty = double.tryParse(value);
                if (qty != null) {
                  Navigator.pop(builderContext, qty);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(builderContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final qty = double.tryParse(qtyController.text);
                  if (qty != null) {
                    Navigator.pop(builderContext, qty);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (countedQty != null) {
        final stockService = ref.read(stockServiceProvider);
        await stockService.addInventoryCountLine(
            _sessionId!, item.id, countedQty);

        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Count recorded'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _completeSession() async {
    if (_sessionId == null) return;

    try {
      final stockService = ref.read(stockServiceProvider);
      await stockService.completeInventoryCount(_sessionId!);

      setState(() {
        _isSessionActive = false;
        _sessionId = null;
        _locationId = null;
        _locationController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock opname completed'),
            backgroundColor: Colors.green,
          ),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Opname'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isSessionActive) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2,
                          size: 64, color: Colors.purple),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location ID',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _createSession,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Create Session'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Session Active',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Location: $_locationId'),
                      Text('Session: ${_sessionId!.substring(0, 8)}...'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _scanAndCount,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan & Count Item'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              if (_sessionId != null) ...[
                Text(
                  'Counted Items',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final linesAsync =
                        ref.watch(inventoryCountLinesProvider(_sessionId!));
                    return linesAsync.when(
                      data: (lines) {
                        if (lines.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No items counted yet'),
                            ),
                          );
                        }
                        return Column(
                          children: lines.map((line) {
                            return Card(
                              child: ListTile(
                                title: Text('Item: ${line.itemId}'),
                                subtitle: Text(
                                    'Counted: ${line.countedQty} | System: ${line.systemQty}'),
                                trailing: Text(
                                  'Variance: ${line.variance > 0 ? '+' : ''}${line.variance}',
                                  style: TextStyle(
                                    color: line.variance == 0
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _completeSession,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Complete Session'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
