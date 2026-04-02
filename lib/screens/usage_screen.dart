import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class UsageScreen extends StatefulWidget {
  final List<Subscription> subscriptions;
  final Function(Subscription)? onMarkUsed;
  const UsageScreen({super.key, required this.subscriptions, this.onMarkUsed});
  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  List<Subscription> get unusedSubscriptions => widget.subscriptions.where((sub) { if (sub.lastUsed == null) return true; return DateTime.now().difference(sub.lastUsed!).inDays > 30; }).toList();
  List<Subscription> get activeSubscriptions => widget.subscriptions.where((sub) { if (sub.lastUsed == null) return false; return DateTime.now().difference(sub.lastUsed!).inDays <= 30; }).toList();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    return Scaffold(
      appBar: AppBar(title: const Text('Usage Tracker'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (unusedSubscriptions.isNotEmpty) ...[Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.warning_amber, color: Colors.orange.shade700), const SizedBox(width: 8), Text('Unused Subscriptions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade800))]), const SizedBox(height: 8), Text('You could save ${currency.format(unusedSubscriptions.fold(0.0, (sum, s) => sum + s.monthlyAmount))}/month', style: TextStyle(color: Colors.orange.shade700))])), const SizedBox(height: 16), ...unusedSubscriptions.map((sub) => _buildCard(sub, currency))],
        const SizedBox(height: 24), const Text('Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        if (activeSubscriptions.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No usage data yet', style: TextStyle(color: Colors.grey)))) else ...activeSubscriptions.map((sub) => _buildCard(sub, currency)),
      ]),
    );
  }

  Widget _buildCard(Subscription sub, NumberFormat currency) {
    final days = sub.lastUsed == null ? null : DateTime.now().difference(sub.lastUsed!).inDays;
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [CircleAvatar(backgroundColor: Colors.redAccent.withOpacity(0.1), child: Text(sub.name[0], style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sub.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(days == null ? 'Never used' : 'Last used $days days ago', style: TextStyle(color: days != null && days > 30 ? Colors.orange : Colors.grey))])), Text(currency.format(sub.amount), style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 12), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _markUsed(sub), icon: const Icon(Icons.check_circle_outline), label: const Text('I Used It'))), const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: () => _cancelDialog(sub), icon: const Icon(Icons.cancel_outlined, color: Colors.red), label: const Text('Cancel', style: TextStyle(color: Colors.red)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red))))])])));
  }

  void _markUsed(Subscription sub) {
    final updated = Subscription(id: sub.id, name: sub.name, amount: sub.amount, billingCycle: sub.billingCycle, renewalDate: sub.renewalDate, category: sub.category, lastUsed: DateTime.now());
    widget.onMarkUsed?.call(updated);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked ${sub.name} as used ✓')));
  }

  void _cancelDialog(Subscription sub) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Cancel Subscription?'), content: Text('Cancel ${sub.name}?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep')), TextButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${sub.name} cancelled 🗡️'))); }, child: const Text('Cancel', style: TextStyle(color: Colors.red)))]));
  }
}