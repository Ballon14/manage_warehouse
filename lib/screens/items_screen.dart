import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_skeleton.dart';
import 'item_detail_screen.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(itemsSearchProvider);
    final itemsAsync = ref.watch(filteredItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or SKU...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(itemsSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                ref.read(itemsSearchProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'Belum Ada Item',
                    message: 'Belum ada item yang ditambahkan. Tap tombol + untuk menambahkan item baru.',
                    onAction: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      
                      final created = await navigator.push<bool>(
                        MaterialPageRoute(builder: (_) => const AddItemScreen()),
                      );
                      
                      if (created == true && mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Item created successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    actionLabel: 'Tambah Item',
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: Key(item.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white, size: 32),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Item?'),
                            content: Text('Yakin ingin menghapus "${item.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final itemService = ref.read(itemServiceProvider);
                          await itemService.deleteItem(item.id);
                          
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('${item.name} dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Gagal hapus item: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: Text(item.name),
                          subtitle: Text('SKU: ${item.sku}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.barcode != null)
                                Chip(
                                  label: Text(
                                    'Barcode: ${item.barcode}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    final navigator = Navigator.of(context);
                                    final messenger = ScaffoldMessenger.of(context);
                                    
                                    final result = await navigator.push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => EditItemScreen(item: item),
                                      ),
                                    );
                                    
                                    if (result == true) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text('Item berhasil diupdate'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else if (value == 'detail') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ItemDetailScreen(itemId: item.id),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'detail',
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline),
                                        SizedBox(width: 8),
                                        Text('Detail'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const SkeletonList(
                itemCount: 8,
                itemHeight: 80,
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          
          final created = await navigator.push<bool>(
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
          
          if (created == true && mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Item created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}
