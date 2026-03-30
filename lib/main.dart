import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SubKillerApp());
}

class SubKillerApp extends StatelessWidget {
  const SubKillerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubKiller',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('subscriptions');
    if (data != null) {
      setState(() {
        _subscriptions = jsonDecode(data);
      });
    } else {
      // Sample data
      _subscriptions = [
        {"name": "Netflix", "amount": 15.99, "cycle": "monthly", "renewal": 5},
        {"name": "Spotify", "amount": 10.99, "cycle": "monthly", "renewal": 12},
        {"name": "Amazon Prime", "amount": 8.99, "cycle": "monthly", "renewal": 20},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SubKiller'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(subscriptions: _subscriptions, onAdd: _addSubscription),
          CalendarScreen(subscriptions: _subscriptions),
          UsageScreen(subscriptions: _subscriptions),
          ReminderScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Usage'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Reminders'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String cycle = "monthly";
showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Subscription"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name (e.g. Netflix)"),),
            const SizedBox(height: 12),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Monthly Cost", prefixText: "£"),),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: cycle,
              items: const [
                DropdownMenuItem(value: "weekly", child: Text("Weekly")),
                DropdownMenuItem(value: "monthly", child: Text("Monthly")),
                DropdownMenuItem(value: "yearly", child: Text("Yearly")),
              ],
              onChanged: (v) => cycle = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          FilledButton(
            onPressed: () {
              final name = nameController.text;
              final amount = double.tryParse(amountController.text);
              if (name.isNotEmpty && amount != null) {
                _addSubscription(name, amount, cycle);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _addSubscription(String name, double amount, String cycle) async {
    final sub = {
      "name": name,
      "amount": amount,
      "cycle": cycle,
      "renewal": 15, // days until renewal
    };
    _subscriptions.add(sub);
    
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('subscriptions', jsonEncode(_subscriptions));
    
    setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name added!")),
      );
    }
  }
}

class DashboardScreen extends StatelessWidget {
  final List subscriptions;
  final Function(String, double, String) onAdd;
  
  const DashboardScreen({super.key, required this.subscriptions, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final total = subscriptions.fold(0.0, (sum, s) => sum + (s["amount"] as num).toDouble());
return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.redAccent, Colors.deepOrange]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text("Monthly Spend", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text("£${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              Text("£${(total * 12).toStringAsFixed(2)} / year", style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber, color: Colors.orange),
            title: Text("${subscriptions.length} subscriptions"),
            subtitle: Text("Total: £${total.toStringAsFixed(2)}/month"),
          ),
        ),
        const SizedBox(height: 16),
        ...subscriptions.map((sub) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.redAccent.withValues(alpha: 0.1), child: Text(sub["name"][0], style: const TextStyle(color: Colors.redAccent))),
            title: Text(sub["name"]),
            subtitle: Text("${sub["cycle"]} - £${sub["amount"]}/month"),
            trailing: Text("£${sub["amount"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        )),
      ],
    );
  }
}

class CalendarScreen extends StatelessWidget {
  final List subscriptions;
  const CalendarScreen({super.key, required this.subscriptions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Renewal Calendar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...subscriptions.map((sub) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.event, color: Colors.redAccent),
            title: Text(sub["name"]),
            subtitle: Text("Renews in ${sub["renewal"]} days"),
          ),
        )),
      ],
    );
  }
}

class UsageScreen extends StatelessWidget {
  final List subscriptions;
  const UsageScreen({super.key, required this.subscriptions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Usage Tracking", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.insights, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text("Track which subs you actually use"),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: subscriptions.map<Widget>((sub) => Chip(label: Text(sub["name"]))).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Reminders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            title: const Text("Email Reminders"),
            subtitle: const Text("Get notified before renewals"),
            value: true,
            onChanged: (v) {},
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.link, color: Colors.green),
            title: Text("Email configured"),
            subtitle: Text("reminder@subkiller.app"),
          ),
        ),
      ],
    );
  }
}
