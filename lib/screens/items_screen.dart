import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_provider.dart';
import '../providers/filter_provider.dart';
import '../models/filter_model.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/search_field_with_history.dart';
import '../widgets/filter_bottom_sheet.dart';
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
        actions: [
          // Filter button
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(filterProvider);
              final hasFilters = filter.hasActiveFilters;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.7,
                          minChildSize: 0.5,
                          maxChildSize: 0.9,
                          builder: (context, scrollController) =>
                              const FilterBottomSheet(),
                        ),
                      );
                    },
                  ),
                  if (hasFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search with History
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchFieldWithHistory(
              controller: _searchController,
              onSearch: (query) {
                ref.read(filterProvider.notifier).setSearchQuery(query);
              },
              hintText: 'Search by name or SKU...',
            ),
          ),

          // Active Filters Chips
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(filterProvider);

              if (!filter.hasActiveFilters) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (filter.stockLevel != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          avatar: Icon(
                            filter.stockLevel!.icon,
                            size: 16,
                            color: filter.stockLevel!.color,
                          ),
                          label: Text(filter.stockLevel!.displayName),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            ref
                                .read(filterProvider.notifier)
                                .setStockLevel(null);
                          },
                        ),
                      ),
                    if (filter.dateRange != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          avatar: const Icon(Icons.date_range, size: 16),
                          label: Text('Date Range'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            ref
                                .read(filterProvider.notifier)
                                .setDateRange(null);
                          },
                        ),
                      ),
                    if (filter.minStock != null || filter.maxStock != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          avatar: const Icon(Icons.numbers, size: 16),
                          label: Text(
                              'Stock: ${filter.minStock?.round() ?? 0}-${filter.maxStock?.round() ?? 1000}'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            ref
                                .read(filterProvider.notifier)
                                .setStockRange(null, null);
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'Belum Ada Item',
                    message:
                        'Belum ada item yang ditambahkan. Tap tombol + untuk menambahkan item baru.',
                    onAction: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      final created = await navigator.push<bool>(
                        MaterialPageRoute(
                            builder: (_) => const AddItemScreen()),
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
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 32),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Item?'),
                            content:
                                Text('Yakin ingin menghapus "${item.name}"?'),
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
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shadowColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.15),
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('SKU: ${item.sku}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.barcode != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Barcode: ${item.barcode}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    final navigator = Navigator.of(context);
                                    final messenger =
                                        ScaffoldMessenger.of(context);

                                    final result = await navigator.push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EditItemScreen(item: item),
                                      ),
                                    );

                                    if (result == true) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Item berhasil diupdate'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else if (value == 'detail') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ItemDetailScreen(itemId: item.id),
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
