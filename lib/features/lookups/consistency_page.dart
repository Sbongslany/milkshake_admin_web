
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/api_service.dart';
import '../../models/consistency.dart';

final consistencyProvider = StateNotifierProvider<ConsistencyNotifier, AsyncValue<List<Consistency>>>(
      (ref) => ConsistencyNotifier(ref),
);

class ConsistencyNotifier extends StateNotifier<AsyncValue<List<Consistency>>> {
  final Ref ref;
  ConsistencyNotifier(this.ref) : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.get('lookups/consistencies');
      final list = (data as List).map((j) => Consistency.fromJson(j)).toList();
      state = AsyncData(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> create(String name, int price) async {
    final api = ref.read(apiServiceProvider);
    await api.post('lookups/consistencies', {'name': name, 'price': price});
    load();
  }

  Future<void> update(String id, String name, int price) async {
    final api = ref.read(apiServiceProvider);
    await api.patch('lookups/consistencies/$id', {'name': name, 'price': price});
    load();
  }

  Future<void> deactivate(String id) async {
    final api = ref.read(apiServiceProvider);
    await api.delete('lookups/consistencies/$id');
    load();
  }
}

class ConsistencyPage extends ConsumerStatefulWidget {
  const ConsistencyPage({super.key});

  @override
  ConsumerState<ConsistencyPage> createState() => _ConsistencyPageState();
}

class _ConsistencyPageState extends ConsumerState<ConsistencyPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isSubmitting = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final consistenciesAsync = ref.watch(consistencyProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consistency Types',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage ice cream texture/density options',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: _getConsistencyColor(colorScheme),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Symbols.ad_group,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Consistency Type',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Define a new ice cream texture or density level',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Consistency Name',
                            prefixIcon: const Icon(Symbols.text_fields),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            hintText: 'e.g., Soft Serve, Gelato, Frozen Yogurt',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'Price Adjustment (Rands)',
                            prefixIcon: const Icon(Symbols.currency_exchange),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            suffixText: 'ZAR',
                            hintText: '0.00 for no charge',
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final doubleValue = double.tryParse(value) ?? 0;
                              _priceController.value = TextEditingValue(
                                text: doubleValue.toStringAsFixed(2),
                                selection: _priceController.selection,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _addConsistency,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getConsistencyColor(colorScheme),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Symbols.add_circle, size: 20),
                        label: Text(
                          _isSubmitting ? 'Adding...' : 'Add Type',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Note: Enter negative value for discount, positive for premium charge',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Search and Stats Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search consistency types...',
                    prefixIcon: const Icon(Symbols.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              consistenciesAsync.when(
                data: (consistencies) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getConsistencyColor(colorScheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getConsistencyColor(colorScheme).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.layers,
                        color: _getConsistencyColor(colorScheme),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${consistencies.length} types',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getConsistencyColor(colorScheme),
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Consistency Types List
          Expanded(
            child: consistenciesAsync.when(
              data: (consistencies) {
                final filteredConsistencies = consistencies
                    .where((c) =>
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                if (filteredConsistencies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.layers_clear,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No consistency types found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Add your first consistency type above'
                              : 'Try a different search term',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filteredConsistencies.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final consistency = filteredConsistencies[index];
                    return _buildConsistencyCard(context, consistency, colorScheme, theme);
                  },
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading consistency types...'),
                  ],
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.error,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load consistency types',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.read(consistencyProvider.notifier).load(),
                      icon: const Icon(Symbols.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyCard(
      BuildContext context,
      Consistency consistency,
      ColorScheme colorScheme,
      ThemeData theme,
      ) {
    final isPremium = consistency.price > 0;
    final isDiscount = consistency.price < 0;
    final priceColor = isPremium
        ? colorScheme.error
        : isDiscount
        ? colorScheme.tertiary ?? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getConsistencyColor(colorScheme).withOpacity(0.2),
                    _getConsistencyColor(colorScheme).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getConsistencyIcon(consistency.name),
                color: _getConsistencyColor(colorScheme),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consistency.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${consistency.id}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: priceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: priceColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPremium
                        ? Symbols.arrow_upward
                        : isDiscount
                        ? Symbols.arrow_downward
                        : Symbols.remove,
                    size: 16,
                    color: priceColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'R${(consistency.price / 100).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: priceColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => _showEditBottomSheet(consistency, colorScheme),
              icon: const Icon(Symbols.edit),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () => _showDeleteDialog(consistency),
              icon: const Icon(Symbols.delete),
              tooltip: 'Delete',
              color: colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addConsistency() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty) {
      _showSnackbar('Please enter a consistency name');
      return;
    }

    final price = (double.tryParse(priceText) ?? 0.0) * 100;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(consistencyProvider.notifier).create(name, price.toInt());
      _nameController.clear();
      _priceController.clear();
      _showSnackbar('Consistency type added successfully');
    } catch (e) {
      _showSnackbar('Failed to add consistency type: $e', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showEditBottomSheet(Consistency consistency, ColorScheme colorScheme) {
    final nameController = TextEditingController(text: consistency.name);
    final priceController =
    TextEditingController(text: (consistency.price / 100).toStringAsFixed(2));
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final sheetColorScheme = Theme.of(context).colorScheme;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Consistency',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Symbols.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Consistency Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price Adjustment (Rands)',
                        border: OutlineInputBorder(),
                        suffixText: 'ZAR',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter negative for discount, positive for premium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: sheetColorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                          final name = nameController.text.trim();
                          final priceText = priceController.text.trim();

                          if (name.isEmpty) {
                            _showSnackbar('Please enter a consistency name');
                            return;
                          }

                          final price =
                              (double.tryParse(priceText) ?? 0.0) * 100;

                          setState(() => isSubmitting = true);
                          try {
                            await ref
                                .read(consistencyProvider.notifier)
                                .update(consistency.id, name, price.toInt());
                            Navigator.pop(context);
                            _showSnackbar('Consistency updated successfully');
                          } catch (e) {
                            _showSnackbar('Failed to update consistency: $e',
                                isError: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getConsistencyColor(sheetColorScheme),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(Consistency consistency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Symbols.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Consistency'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${consistency.name}"? This will remove it from all menu options.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(consistencyProvider.notifier).deactivate(consistency.id);
              Navigator.pop(context);
              _showSnackbar('Consistency deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? colorScheme.error
            : _getConsistencyColor(colorScheme),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Color _getConsistencyColor(ColorScheme colorScheme) {
    return colorScheme.secondaryContainer;
  }

  IconData _getConsistencyIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('soft') || lowerName.contains('serve')) {
      return Symbols.icecream;
    } else if (lowerName.contains('gelato')) {
      return Symbols.cookie;
    } else if (lowerName.contains('frozen') || lowerName.contains('yogurt')) {
      return Symbols.local_drink;
    } else if (lowerName.contains('hard') || lowerName.contains('scoop')) {
      return Symbols.icecream;
    } else if (lowerName.contains('whipped')) {
      return Symbols.auto_fix_high;
    }
    return Symbols.ad_group;
  }
}