import 'package:flutter/material.dart';
import '../models/subscription.dart';

class ReminderSettingsScreen extends StatefulWidget {
  final List<Subscription> subscriptions;
  const ReminderSettingsScreen({super.key, required this.subscriptions});
  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  Map<String, bool> _reminderDays = {'1': false, '3': true, '7': false, '14': false};
  bool _emailReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: SwitchListTile(title: const Text('Email Reminders'), subtitle: const Text('Get notified before renewals'), value: _emailReminders, onChanged: (v) => setState(() => _emailReminders = v))),
        const SizedBox(height: 16),
        const Text('Remind Me Before', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        Wrap(spacing: 8, children: _reminderDays.entries.map((e) => FilterChip(label: Text('${e.key} days'), selected: e.value, onSelected: (s) => setState(() => _reminderDays[e.key] = s))).toList()),
        const SizedBox(height: 24),
        const Text('Upcoming Reminders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        ...widget.subscriptions.where((s) => s.daysUntilRenewal <= 14).map((sub) => Card(child: ListTile(leading: CircleAvatar(backgroundColor: sub.daysUntilRenewal <= 3 ? Colors.red : Colors.orange, child: Text('${sub.daysUntilRenewal}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), title: Text(sub.name), subtitle: Text(sub.daysUntilRenewal == 0 ? 'Due today!' : 'Renews in ${sub.daysUntilRenewal} days'), trailing: const Icon(Icons.notifications_active, color: Colors.orange)))),
        if (widget.subscriptions.where((s) => s.daysUntilRenewal <= 14).isEmpty) const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No renewals in next 2 weeks', style: TextStyle(color: Colors.grey)))),
        const SizedBox(height: 24),
        if (_emailReminders) ...[const Text('Email Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('📧 Subject: SubKiller Reminder', style: TextStyle(fontWeight: FontWeight.bold)), const Divider(), Text('Your Netflix renews soon. Haven\'t used it? You could save money. — SubKiller 🗡️')]))],
        const SizedBox(height: 32),
        FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved ✓'))), icon: const Icon(Icons.save), label: const Text('Save Settings')),
      ]),
    );
  }
}
