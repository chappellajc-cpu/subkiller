import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class UsageScreen extends StatefulWidget {
  final List<Subscription> subscriptions;
  final Function(Subscription)? onMarkUsed;
  final Function(Subscription)? onCancelSubscription;
  const UsageScreen({super.key, required this.subscriptions, this.onMarkUsed, this.onCancelSubscription});
  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  static const Map<String, String> serviceDomains = {
    'netflix': 'netflix.com', 'spotify': 'spotify.com', 'amazon prime': 'amazon.com',
    'prime': 'amazon.com', 'amazonprime': 'amazon.com', 'prime video': 'primevideo.com', 
    'apple': 'apple.com', 'disney': 'disneyplus.com', 'hbo': 'hbomax.com', 'youtube': 'youtube.com', 
    'microsoft': 'microsoft.com', 'google': 'google.com', 'dropbox': 'dropbox.com', 'adobe': 'adobe.com',
    'notion': 'notion.so', 'slack': 'slack.com', 'zoom': 'zoom.us', 'nordvpn': 'nordvpn.com',
  };

  static String? getServiceLogo(String name) {
    final key = name.toLowerCase().trim();
    String? domain;
    // Direct match
    if (serviceDomains.containsKey(key)) {
      domain = serviceDomains[key];
    } else {
      // Partial match - check if any key is part of the name
      for (final serviceKey in serviceDomains.keys) {
        if (key.contains(serviceKey) || serviceKey.length > 3 && key.contains(serviceKey.substring(0, serviceKey.length - 1))) {
          domain = serviceDomains[serviceKey];
          break;
        }
      }
    }
    if (domain == null && key.length > 3) {
      // Try extracting first word as potential service
      final firstWord = key.split(' ').first;
      if (serviceDomains.containsKey(firstWord)) {
        domain = serviceDomains[firstWord];
      }
    }
    return domain != null ? 'https://icons.duckduckgo.com/ip3/$domain.ico' : null;
  }

  List<Subscription> get unusedSubscriptions => widget.subscriptions.where((sub) => sub.isCancelled == false && (sub.lastUsed == null || DateTime.now().difference(sub.lastUsed!).inDays > 30)).toList();
  List<Subscription> get activeSubscriptions => widget.subscriptions.where((sub) => sub.isCancelled == false && sub.lastUsed != null && DateTime.now().difference(sub.lastUsed!).inDays <= 30).toList();
  List<Subscription> get cancelledSubscriptions => widget.subscriptions.where((sub) => sub.isCancelled).toList();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    return Scaffold(
      appBar: AppBar(title: const Text('Usage Tracker'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (unusedSubscriptions.isNotEmpty) ...[
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.warning_amber, color: Colors.orange.shade700), const SizedBox(width: 8), Text('Unused Subscriptions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade800))]), const SizedBox(height: 8), Text('You could save ${currency.format(unusedSubscriptions.fold(0.0, (sum, s) => sum + s.monthlyAmount))}/month', style: TextStyle(color: Colors.orange.shade700))])),
          const SizedBox(height: 16),
          ...unusedSubscriptions.map((sub) => _buildCard(sub, currency))
        ],
        const SizedBox(height: 24), const Text('Active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        if (activeSubscriptions.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No usage data yet', style: TextStyle(color: Colors.grey)))) else ...activeSubscriptions.map((sub) => _buildCard(sub, currency)),
        if (cancelledSubscriptions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)), child: Row(children: [Icon(Icons.cancel, color: Colors.red.shade700), const SizedBox(width: 8), Text('Cancellation Pending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700))])),
          const SizedBox(height: 8),
          ...cancelledSubscriptions.map((sub) => _buildCancelledCard(sub, currency))
        ],
      ]),
    );
  }

  Widget _buildLogo(String name, Color color, double size) {
    final logoUrl = getServiceLogo(name);
    if (logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.2))),
          child: Image.network(logoUrl, width: size, height: size, fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) => CircleAvatar(radius: size/2, backgroundColor: color.withOpacity(0.2), child: Text(name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: size*0.4)))),
        ),
      );
    }
    return CircleAvatar(radius: size/2, backgroundColor: color.withOpacity(0.2), child: Text(name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: size*0.4)));
  }

  Widget _buildCard(Subscription sub, NumberFormat currency) {
    final days = sub.lastUsed == null ? null : DateTime.now().difference(sub.lastUsed!).inDays;
    final color = Colors.redAccent;
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Row(children: [
        _buildLogo(sub.name, color, 44),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sub.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(days == null ? 'Never used' : 'Last used $days days ago', style: TextStyle(color: days != null && days > 30 ? Colors.orange : Colors.grey)),
        ])),
        Text(currency.format(sub.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: () => _markUsed(sub), icon: const Icon(Icons.check_circle_outline), label: const Text('I Used It'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: () => _cancelDialog(sub), icon: const Icon(Icons.cancel_outlined, color: Colors.red), label: const Text('Cancel'), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red))),
      ]),
    ])));
  }

  Widget _buildCancelledCard(Subscription sub, NumberFormat currency) {
    final color = Colors.red;
    return Card(margin: const EdgeInsets.only(bottom: 12), color: Colors.red.shade50, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Row(children: [
        _buildLogo(sub.name, color, 44),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sub.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
          Text('Cancel pending', style: TextStyle(color: color, fontSize: 12)),
        ])),
        Text(currency.format(sub.amount), style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: () => _confirmDelete(sub), icon: const Icon(Icons.delete_forever), label: const Text('Confirm'), style: FilledButton.styleFrom(backgroundColor: color))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: () => _undoCancel(sub), icon: const Icon(Icons.undo), label: const Text('Undo'))),
      ]),
    ])));
  }

  void _markUsed(Subscription sub) {
    final updated = sub.copyWith(lastUsed: DateTime.now());
    widget.onMarkUsed?.call(updated);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked ${sub.name} as used ✓')));
  }

  void _cancelDialog(Subscription sub) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Cancel Subscription?'),
      content: Text('Mark ${sub.name} as cancelled?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep')),
        TextButton(onPressed: () { Navigator.pop(ctx); final updated = sub.copyWith(isCancelled: true); widget.onCancelSubscription?.call(updated); }, child: const Text('Mark Cancelled')),
      ],
    ));
  }

  void _confirmDelete(Subscription sub) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirm Delete?'),
      content: Text('Remove ${sub.name} permanently?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not Yet')),
        TextButton(onPressed: () { Navigator.pop(ctx); widget.onCancelSubscription?.call(sub); }, child: const Text('Confirm', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _undoCancel(Subscription sub) {
    final updated = sub.copyWith(isCancelled: false);
    widget.onCancelSubscription?.call(updated);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${sub.name} reinstated ✓')));
  }
}