
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/api_service.dart';
import '../../models/config.dart';

final configProvider = StateNotifierProvider<ConfigNotifier, AsyncValue<Config>>(
      (ref) => ConfigNotifier(ref),
);

class ConfigNotifier extends StateNotifier<AsyncValue<Config>> {
  final Ref ref;
  ConfigNotifier(this.ref) : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.get('config');
      state = AsyncData(Config.fromJson(data));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> update(Config newConfig) async {
    try {
      state = AsyncData(newConfig);
      final api = ref.read(apiServiceProvider);
      await api.patch('config', newConfig.toJson());
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  late Config _config;
  final List<DiscountTier> _tiers = [];
  final _vatRateController = TextEditingController();
  final _minDrinksController = TextEditingController();
  final _maxDrinksController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _vatRateController.dispose();
    _minDrinksController.dispose();
    _maxDrinksController.dispose();
    _maxDiscountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(configProvider);

    return configAsync.when(
      data: (config) {
        _config = config;
        _initializeControllers();
        return _buildForm();
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading configuration...'),
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
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load configuration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(configProvider.notifier).load(),
              icon: const Icon(Symbols.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeControllers() {
    if (_vatRateController.text.isEmpty) {
      _vatRateController.text = _config.vatRate.toString();
      _minDrinksController.text = _config.minDrinks.toString();
      _maxDrinksController.text = _config.maxDrinks.toString();
      _maxDiscountController.text = _config.maxDiscountPercent.toString();
      _tiers.clear();
      _tiers.addAll(_config.discountTiers);
    }
  }

  Widget _buildForm() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Configuration',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage global system settings and rules',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Symbols.settings,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tax Configuration Card
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
                    Row(
                      children: [
                        Icon(
                          Symbols.account_balance,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tax Configuration',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure Value Added Tax (VAT) settings',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _vatRateController,
                      decoration: InputDecoration(
                        labelText: 'VAT Rate (%)',
                        prefixIcon: const Icon(Symbols.percent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter VAT rate';
                        }
                        final rate = int.tryParse(value);
                        if (rate == null || rate < 0 || rate > 100) {
                          return 'Enter a valid percentage (0-100)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Drink Limits Card
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
                    Row(
                      children: [
                        Icon(
                          Symbols.local_drink,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Drink Order Limits',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set minimum and maximum drinks per order',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minDrinksController,
                            decoration: InputDecoration(
                              labelText: 'Minimum Drinks',
                              prefixIcon: const Icon(Icons.production_quantity_limits),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter minimum';
                              }
                              final min = int.tryParse(value);
                              if (min == null || min < 0) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxDrinksController,
                            decoration: InputDecoration(
                              labelText: 'Maximum Drinks',
                              prefixIcon: const Icon(Symbols.exposure_plus_1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter maximum';
                              }
                              final max = int.tryParse(value);
                              final min = int.tryParse(_minDrinksController.text);
                              if (max == null || max < 0) {
                                return 'Enter a valid number';
                              }
                              if (min != null && max < min) {
                                return 'Max must be ≥ Min';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Discount Configuration Card
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
                    Row(
                      children: [
                        Icon(
                          Icons.discount,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loyalty Discount Tiers',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure discount tiers based on past orders',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _maxDiscountController,
                      decoration: InputDecoration(
                        labelText: 'Maximum Discount (%)',
                        prefixIcon: const Icon(Icons.production_quantity_limits),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter maximum discount';
                        }
                        final max = int.tryParse(value);
                        if (max == null || max < 0 || max > 100) {
                          return 'Enter a valid percentage (0-100)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Discount Tiers
                    const Text(
                      'Discount Tiers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add tiers to reward loyal customers based on their order history',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_tiers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.info,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No discount tiers configured. Add tiers to enable loyalty discounts.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ..._tiers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tier = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
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
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _DiscountTierField(
                                    label: 'Minimum Orders',
                                    initialValue: tier.minPastOrders.toString(),
                                    onChanged: (value) {
                                      final min = int.tryParse(value);
                                      if (min != null) {
                                        _tiers[index] = DiscountTier(
                                          minPastOrders: min,
                                          discountPercent: tier.discountPercent,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _DiscountTierField(
                                    label: 'Discount %',
                                    initialValue: tier.discountPercent.toString(),
                                    onChanged: (value) {
                                      final discount = int.tryParse(value);
                                      if (discount != null) {
                                        _tiers[index] = DiscountTier(
                                          minPastOrders: tier.minPastOrders,
                                          discountPercent: discount,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _tiers.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Symbols.delete),
                                  color: colorScheme.error,
                                  tooltip: 'Remove Tier',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _tiers.add(DiscountTier(
                            minPastOrders: _tiers.isNotEmpty
                                ? _tiers.last.minPastOrders + 5
                                : 5,
                            discountPercent: _tiers.isNotEmpty
                                ? _tiers.last.discountPercent + 5
                                : 5,
                          ));
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        foregroundColor: colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Symbols.add),
                      label: const Text('Add Discount Tier'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Symbols.save),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Configuration',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedConfig = Config(
      vatRate: int.parse(_vatRateController.text),
      minDrinks: int.parse(_minDrinksController.text),
      maxDrinks: int.parse(_maxDrinksController.text),
      discountTiers: List.from(_tiers),
      maxDiscountPercent: int.parse(_maxDiscountController.text),
    );

    setState(() => _isSaving = true);
    try {
      await ref.read(configProvider.notifier).update(updatedConfig);
      _showSnackbar('Configuration saved successfully');
    } catch (e) {
      _showSnackbar('Failed to save configuration: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _DiscountTierField extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _DiscountTierField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_DiscountTierField> createState() => _DiscountTierFieldState();
}

class _DiscountTierFieldState extends State<_DiscountTierField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_DiscountTierField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixText: widget.label.contains('%') ? '%' : null,
      ),
      keyboardType: TextInputType.number,
      onChanged: widget.onChanged,
    );
  }
}