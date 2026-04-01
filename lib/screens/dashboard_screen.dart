import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import 'add_subscription_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<Subscription>? subscriptions;
  final VoidCallback? onToggleTheme;
  const DashboardScreen({super.key, this.subscriptions, this.onToggleTheme});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Subscription> _subscriptions = [];
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedBillingCycle;
  
  @override
  void initState() {
    super.initState();
    _subscriptions = widget.subscriptions ?? _loadSampleData();
  }

  List<Subscription> get filteredSubscriptions {
    return _subscriptions.where((sub) {
      if (_searchQuery.isNotEmpty && !sub.name.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      if (_selectedCategory != null && sub.category != _selectedCategory) return false;
      if (_selectedBillingCycle != null && sub.billingCycle != _selectedBillingCycle) return false;
      return true;
    }).toList();
  }

  static const Map<String, Color> categoryColors = {
    'Entertainment': Colors.purple, 'Music': Colors.green, 'Productivity': Colors.blue,
    'Cloud Storage': Colors.cyan, 'Gaming': Colors.red, 'News': Colors.orange,
    'Fitness': Colors.teal, 'Shopping': Colors.pink, 'Health': Colors.green, 'Other': Colors.grey,
  };

  static Color getCategoryColor(String? category) => categoryColors[category] ?? Colors.grey;

  String _generateCSV() {
    final headers = 'Name,Amount,Billing Cycle,Category,Renewal Date,Monthly Amount';
    final rows = filteredSubscriptions.map((sub) => '${sub.name},${sub.amount},${sub.billingCycle},${sub.category ?? "Other"},${DateFormat.yMMMd().format(sub.renewalDate)},${sub.monthlyAmount.toStringAsFixed(2)}').join('\n');
    return '$headers\n$rows';
  }

  Future<void> _exportCSV() async {
    final csv = _generateCSV();
    await Clipboard.setData(ClipboardData(text: csv));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📋 CSV copied to clipboard!'), backgroundColor: Colors.green));
  }

  List<String> get availableCategories {
    final cats = _subscriptions.map((s) => s.category).where((c) => c != null).cast<String>().toSet().toList();
    return cats.isEmpty ? ['Entertainment', 'Shopping', 'Productivity', 'Health', 'News'] : cats;
  }

  Map<String, double> get spendingByCategory {
    final Map<String, double> spending = {};
    for (final sub in filteredSubscriptions) {
      final cat = sub.category ?? 'Other';
      spending[cat] = (spending[cat] ?? 0) + sub.monthlyAmount;
    }
    return spending;
  }

  List<Subscription> _loadSampleData() {
    return [
      Subscription(id: '1', name: 'Netflix', amount: 15.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 5)), category: 'Entertainment'),
      Subscription(id: '2', name: 'Spotify', amount: 10.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 12)), category: 'Entertainment'),
      Subscription(id: '3', name: 'Amazon Prime', amount: 8.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 20)), category: 'Shopping'),
    ];
  }

  double get totalMonthly => filteredSubscriptions.fold(0, (sum, sub) => sum + sub.monthlyAmount);
  double get totalYearly => totalMonthly * 12;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final isDark = Theme.of(context).brightne
ss == Brightness.dark;
return
Scaffold(
      appBar: AppBar(
        title: const Text('SubKiller'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: _exportCSV, tooltip: 'Export to CSV'),
          IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), onPressed: widget.onToggleTheme, tooltip: isDark ? 'Light Mode' : 'Dark Mode'),
        ],
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(hintText: 'Search subscriptions...', prefixIcon: const Icon(Icons.search), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = '')) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        )),
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          PopupMenuButton<String?>(initialValue: _selectedCategory, onSelected: (v) => setState(() => _selectedCategory = v), itemBuilder: (ctx) => [const PopupMenuItem(value: null, child: Text('All Categories')), ...availableCategories.map((c) => PopupMenuItem(value: c, child: Text(c)))], child: Chip(label: Text(_selectedCategory ?? 'Category'), avatar: const Icon(Icons.category, size: 18))),
          const SizedBox(width: 8),
          PopupMenuButton<String?>(initialValue: _selectedBillingCycle, onSelected: (v) => setState(() => _selectedBillingCycle = v), itemBuilder: (ctx) => [const PopupMenuItem(value: null, child: Text('All Cycles')), const PopupMenuItem(value: 'monthly', child: Text('Monthly')), const PopupMenuItem(value: 'yearly', child: Text('Yearly'))], child: Chip(label: Text(_selectedBillingCycle ?? 'Billing Cycle'), avatar: const Icon(Icons.repeat, size: 18))),
          const SizedBox(width: 8),
          if (_selectedCategory != null || _selectedBillingCycle != null) ActionChip(avatar: const Icon(Icons.clear, size: 18), label: const Text('Clear'), onPressed: () => setState(() { _selectedCategory = null; _selectedBillingCycle = null; })),
        ])),
        const SizedBox(height: 8),
        Container(width: double.infinity, margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.redAccent, Colors.deepOrange]), borderRadius: BorderRadius.circular(16)), child: Column(children: [
          const Text('Monthly Spend', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(currency.format(totalMonthly), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          Text('${currency.format(totalYearly)} / year', style: const TextStyle(color: Colors.white70)),
        ])),
        if (spendingByCategory.isNotEmpty) ...[Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Spending by Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800))), const SizedBox(height: 8), SizedBox(height: 80, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: spendingByCategory.length, itemBuilder: (context, index) {
          final category = spendingByCategory.keys.elementAt(index);
          final amount = spendingByCategory[category]!;
          return Container(width: 120, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: getCategoryColor(category).withOpacity(0.15), borderRadius: BorderRadiu
s
.circular(12), border: Border.all(color: getCategoryColor(category).wit
hOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(category, style: TextStyle(fontSize: 12, color: getCategoryColor(category), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text(currency.format(amount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]));
        })), const SizedBox(height: 16)],
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Upcoming Renewals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('${filteredSubscriptions.length} active', style: TextStyle(color: Colors.grey.shade600))])),
        const SizedBox(height: 8),
        Expanded(child: filteredSubscriptions.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), Text('No subscriptions found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600))])) : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: filteredSubscriptions.length, itemBuilder: (context, index) {
          final sub = filteredSubscriptions[index];
          final catColor = getCategoryColor(sub.category);
          return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(leading: CircleAvatar(backgroundColor: catColor.withOpacity(0.2), child: Text(sub.name[0], style: TextStyle(color: catColor, fontWeight: FontWeight.bold))), title: Text(sub.name), subtitle: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(sub.category ?? 'Other', style: TextStyle(fontSize: 10, color: catColor))), const SizedBox(width: 8), Text(sub.daysUntilRenewal == 0 ? 'Due today!' : 'Renews in ${sub.daysUntilRenewal} days', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]), trailing: Text(currency.format(sub.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))));
        })),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSubscriptionScreen())), icon: const Icon(Icons.add), label: const Text('Add'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
    );
  }
}
