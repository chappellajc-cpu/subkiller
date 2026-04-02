import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;
  const AddSubscriptionScreen({super.key, this.subscription});
  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _billingCycle;
  late DateTime _renewalDate;
  String? _category;
  bool get isEditing => widget.subscription != null;

  final _categories = ['Entertainment', 'Music', 'Productivity', 'Cloud Storage', 'Gaming', 'News', 'Fitness', 'Shopping', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subscription?.name ?? '');
    _amountController = TextEditingController(text: widget.subscription?.amount.toString() ?? '');
    _billingCycle = widget.subscription?.billingCycle ?? 'monthly';
    _renewalDate = widget.subscription?.renewalDate ?? DateTime.now().add(const Duration(days: 30));
    _category = widget.subscription?.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final subscription = Subscription(
        id: widget.subscription?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        billingCycle: _billingCycle,
        renewalDate: _renewalDate,
        category: _category,
        lastUsed: widget.subscription?.lastUsed,
      );
      Navigator.pop(context, subscription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subscription' : 'Add Subscription'), 
        backgroundColor: Colors.redAccent, 
        foregroundColor: Colors.white,
      ),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Service Name', hintText: 'e.g., Netflix', prefixIcon: Icon(Icons.subscriptions)), validator: (v) => v!.isEmpty ? 'Required' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount', prefixIcon: Icon(Icons.attach_money)), validator: (v) => double.tryParse(v!) == null ? 'Invalid' : null),
        const SizedBox(height: 16),
        DropdownButtonFormField(value: _billingCycle, decoration: const InputDecoration(labelText: 'Billing Cycle', prefixIcon: Icon(Icons.repeat)), items: const [DropdownMenuItem(value: 'weekly', child: Text('Weekly')), DropdownMenuItem(value: 'monthly', child: Text('Monthly')), DropdownMenuItem(value: 'yearly', child: Text('Yearly'))], onChanged: (v) => setState(() => _billingCycle = v!)),
        const SizedBox(height: 16),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today), title: const Text('Next Renewal'), subtitle: Text(DateFormat.yMMMd().format(_renewalDate)), onTap: () async {
          final d = await showDatePicker(context: context, initialDate: _renewalDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (d != null) setState(() => _renewalDate = d);
        }),
        const SizedBox(height: 16),
        DropdownButtonFormField(value: _category, decoration: const InputDecoration(labelText: 'Category (optional)', prefixIcon: Icon(Icons.category)), items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _category = v)),
        const SizedBox(height: 32),
        FilledButton.icon(onPressed: _submit, icon: Icon(isEditing ? Icons.save : Icons.add), label: Text(isEditing ? 'Save Changes' : 'Add Subscription'), style: FilledButton.styleFrom(backgroundColor: Colors.redAccent)),
      ])),
    );
  }
}