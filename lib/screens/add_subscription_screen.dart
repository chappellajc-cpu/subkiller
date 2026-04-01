import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});
  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _billingCycle = 'monthly';
  DateTime _renewalDate = DateTime.now().add(const Duration(days: 30));
  String? _category;

  final _categories = ['Entertainment', 'Music', 'Productivity', 'Cloud Storage', 'Gaming', 'News', 'Fitness', 'Shopping', 'Other'];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final subscription = Subscription(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameController.text, amount: double.parse(_amountController.text), billingCycle: _billingCycle, renewalDate: _renewalDate, category: _category);
      Navigator.pop(context, subscription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Service Name', hintText: 'e.g., Netflix', prefixIcon: Icon(Icons.subscriptions)), validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.attach_money)), validator: (v) => double.tryParse(v!) == null ? 'Invalid' : null),
        const SizedBox(height: 16),
        DropdownButtonFormField(value: _billingCycle, decoration: const InputDecoration(labelText: 'Billing Cycle', prefixIcon: Icon(Icons.repeat)), items: const [DropdownMenuItem(value: 'weekly', child: Text('Weekly')), DropdownMenuItem(value: 'monthly', child: Text('Monthly')), DropdownMenuItem(value: 'yearly', child: Text('Yearly'))], onChanged: (v) => setState(() => _billingCycle = v!)),
        const SizedBox(height: 16),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today), title: const Text('Next Renewal'), subtitle: Text(DateFormat.yMMMd().format(_renewalDate)), onTap: () async {
          final d = await showDatePicker(context: context, initialDate: _renewalDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (d != null) setState(() => _renewalDate = d);
        }),
        const SizedBox(height: 16),
        DropdownButtonFormField(value: _category, decoration: const InputDecoration(labelText: 'Category (optional)', prefixIcon: Icon(Icons.category)), items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _category = v)),
        const SizedBox(height: 32),
        FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.add), label: const Text('Add Subscription'), style: FilledButton.styleFrom(backgroundColor: Colors.redAccent)),
      ])),
    );
  }
}
