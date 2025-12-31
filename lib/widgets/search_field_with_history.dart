import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';

/// Search field with history dropdown
class SearchFieldWithHistory extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final String hintText;

  const SearchFieldWithHistory({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search items...',
  });

  @override
  ConsumerState<SearchFieldWithHistory> createState() =>
      _SearchFieldWithHistoryState();
}

class _SearchFieldWithHistoryState
    extends ConsumerState<SearchFieldWithHistory> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showHistoryDropdown();
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        _removeOverlay();
      });
    }
  }

  void _showHistoryDropdown() {
    final history = ref.read(filterProvider.notifier).getSearchHistory();
    if (history.isEmpty) return;

    _removeOverlay();

    _overlayEntry = _createOverlayEntry(history);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(List<String> history) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Searches',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(filterProvider.notifier)
                                .clearSearchHistory();
                            _removeOverlay();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  // History items
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final query = history[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.history,
                            size: 20,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                          title: Text(query),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              ref
                                  .read(filterProvider.notifier)
                                  .removeFromHistory(query);
                              if (ref
                                  .read(filterProvider.notifier)
                                  .getSearchHistory()
                                  .isEmpty) {
                                _removeOverlay();
                              } else {
                                // Rebuild overlay with updated history
                                final newHistory = ref
                                    .read(filterProvider.notifier)
                                    .getSearchHistory();
                                _overlayEntry?.remove();
                                _overlayEntry = _createOverlayEntry(newHistory);
                                Overlay.of(context).insert(_overlayEntry!);
                              }
                            },
                          ),
                          onTap: () {
                            widget.controller.text = query;
                            widget.onSearch(query);
                            _removeOverlay();
                            _focusNode.unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          setState(() {}); // Rebuild to show/hide clear button
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            widget.onSearch(value);
            _removeOverlay();
          }
        },
      ),
    );
  }
}
