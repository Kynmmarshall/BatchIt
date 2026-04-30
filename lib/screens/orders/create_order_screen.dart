import 'package:batchit/l10n/app_localizations.dart';
import 'package:batchit/models/order.dart';
import 'package:batchit/providers/order_provider.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:batchit/widgets/app_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  String _product = 'Potatoes';
  final TextEditingController _quantityController = TextEditingController(text: '1');
  String _hub = 'Hub Ain Sebaa';

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text('Create Order')),
      body: AppScreenContainer(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Create Order', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(children: [
                DropdownButtonFormField<String>(
                  value: _product,
                  items: const [
                    DropdownMenuItem(value: 'Potatoes', child: Text('Potatoes')),
                    DropdownMenuItem(value: 'Tomatoes', child: Text('Tomatoes')),
                    DropdownMenuItem(value: 'Onions', child: Text('Onions')),
                  ],
                  onChanged: (v) => setState(() => _product = v ?? _product),
                  decoration: InputDecoration(labelText: l10n.productSelection),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.quantity),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: _hub,
                  items: const [
                    DropdownMenuItem(value: 'Hub Ain Sebaa', child: Text('Hub Ain Sebaa')),
                    DropdownMenuItem(value: 'Hub Centre', child: Text('Hub Centre')),
                    DropdownMenuItem(value: 'Hub East', child: Text('Hub East')),
                  ],
                  onChanged: (v) => setState(() => _hub = v ?? _hub),
                  decoration: InputDecoration(labelText: l10n.hub),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    final qty = double.tryParse(_quantityController.text.trim()) ?? 1;
                    final order = Order(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      productName: _product,
                      quantityKg: qty,
                      status: OrderStatus.pending,
                      hubName: _hub,
                    );
                    context.read<OrderProvider>().addOrder(order);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.myOrders)));
                    Navigator.pop(context);
                  },
                  child: Text(l10n.submit),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
