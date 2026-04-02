import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import 'add_subscription_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<Subscription>? subscriptions;
  final VoidCallback? onToggleTheme;
  final Function(Subscription)? onAddSubscription;
  final Function(Subscription)? onUpdateSubscription;
  final Function(String)? onDeleteSubscription;
  const DashboardScreen({super.key, this.subscriptions, this.onToggleTheme, this.onAddSubscription, this.onUpdateSubscription, this.onDeleteSubscription});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Subscription> _subscriptions = [];
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  List<String> _selectedBillingCycles = [];
  
  @override
  void initState() {
    super.initState();
    _subscriptions = widget.subscriptions ?? _loadSampleData();
  }

  List<Subscription> get filteredSubscriptions {
    return _subscriptions.where((sub) {
      if (_searchQuery.isNotEmpty && !sub.name.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      if (_selectedCategories.isNotEmpty && !_selectedCategories.contains(sub.category)) return false;
      if (_selectedBillingCycles.isNotEmpty && !_selectedBillingCycles.contains(sub.billingCycle)) return false;
      return true;
    }).toList();
  }

  static const Map<String, Color> categoryColors = {
    'Entertainment': Colors.purple, 'Music': Colors.green, 'Productivity': Colors.blue,
    'Cloud Storage': Colors.cyan, 'Gaming': Colors.red, 'News': Colors.orange,
    'Fitness': Colors.teal, 'Shopping': Colors.pink, 'Health': Colors.green, 'Other': Colors.grey,
  };

  static const Map<String, String> serviceDomains = {
    'netflix': 'netflix.com',
    'spotify': 'spotify.com',
    'amazon prime': 'amazon.com',
    'amazonprime': 'amazon.com',
    'amazon': 'amazon.com',
    'prime video': 'primevideo.com',
    'apple': 'apple.com',
    'apple music': 'music.apple.com',
    'apple tv': 'tv.apple.com',
    'disney': 'disneyplus.com',
    'disney plus': 'disneyplus.com',
    'hbo': 'hbomax.com',
    'hbo max': 'max.com',
    'youtube': 'youtube.com',
    'youtube premium': 'youtube.com',
    'microsoft': 'microsoft.com',
    'google': 'google.com',
    'dropbox': 'dropbox.com',
    'icloud': 'icloud.com',
    'adobe': 'adobe.com',
    'notion': 'notion.so',
    'slack': 'slack.com',
    'zoom': 'zoom.us',
    'nordvpn': 'nordvpn.com',
    'gym': 'gymshark.com',
    'fitness': 'gymshark.com',
    'amazon prime video': 'primevideo.com',
    'samsung': 'samsung.com',
    'sky': 'sky.com',
    'now tv': 'nowtv.com',
    'bt': 'bt.com',
    'virgin': 'virginmedia.com',
    'barclays': 'barclays.co.uk',
    'monzo': 'monzo.com',
    'revolut': 'revolut.com',
    'paypal': 'paypal.com',
    'wine': 'winedirect.com',
    'kindle': 'amazon.co.uk',
    'audible': 'audible.co.uk',
    'duolingo': 'duolingo.com',
    'chatgpt': 'chatgpt.com',
    'copilot': 'copilot.microsoft.com',
    'clash': 'clashofclans.com',
    'candy crush': 'candycrush.com',
  };

  static String? getServiceLogo(String name) {
    final key = name.toLowerCase().trim();
    String? domain;
    
    if (serviceDomains.containsKey(key)) {
      domain = serviceDomains[key];
    } else {
      for (final service in serviceDomains.keys) {
        if (key.contains(service)) {
          domain = serviceDomains[service];
          break;
        }
      }
    }
    
    if (domain != null) {
      // Use Google's favicon service with direct URLs
      return 'https://www.google.com/s2/favicons?domain=$domain&sz=64';
    }
    return null;
  }

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
      Subscription(id: '2', name: 'Spotify', amount: 10.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 12)), category: 'Music'),
      Subscription(id: '3', name: 'Amazon Prime', amount: 8.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 20)), category: 'Shopping'),
    ];
  }

  double get totalMonthly => filteredSubscriptions.fold(0, (sum, sub) => sum + sub.monthlyAmount);
  double get totalYearly => totalMonthly * 12;

  void _showCategoryFilter() {
    showModalBottomSheet(context: context, builder: (ctx) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Filter by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: availableCategories.map((c) => FilterChip(
          label: Text(c),
          selected: _selectedCategories.contains(c),
          onSelected: (selected) => setState(() {
            if (selected) {
              _selectedCategories.add(c);
            } else {
              _selectedCategories.remove(c);
            }
          }),
        )).toList()),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => _selectedCategories.clear()), child: const Text('Clear All')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Apply')),
        ]),
      ]),
    ));
  }

  void _showBillingCycleFilter() {
    final cycles = ['monthly', 'yearly', 'weekly'];
    showModalBottomSheet(context: context, builder: (ctx) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Filter by Billing Cycle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: cycles.map((c) => FilterChip(
          label: Text(c == 'monthly' ? 'Monthly' : c == 'yearly' ? 'Yearly' : 'Weekly'),
          selected: _selectedBillingCycles.contains(c),
          onSelected: (selected) => setState(() {
            if (selected) {
              _selectedBillingCycles.add(c);
            } else {
              _selectedBillingCycles.remove(c);
            }
          }),
        )).toList()),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(onPressed: () => setState(() => _selectedBillingCycles.clear()), child: const Text('Clear All')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Apply')),
        ]),
      ]),
    ));
  }

  void _showSubscriptionDetails(Subscription sub) {
    final currency = NumberFormat.currency(symbol: '\$');
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(sub.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          Row(children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {
              Navigator.pop(ctx);
              _editSubscription(sub);
            }),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
              Navigator.pop(ctx);
              _confirmDelete(sub);
            }),
          ]),
        ]),
        const SizedBox(height: 16),
        _detailRow('Amount', currency.format(sub.amount)),
        _detailRow('Billing Cycle', sub.billingCycle == 'monthly' ? 'Monthly' : sub.billingCycle == 'yearly' ? 'Yearly' : 'Weekly'),
        _detailRow('Category', sub.category ?? 'Other'),
        _detailRow('Renewal Date', DateFormat.yMMMd().format(sub.renewalDate)),
        _detailRow('Next Payment', '${sub.daysUntilRenewal} days'),
        _detailRow('Monthly Cost', currency.format(sub.monthlyAmount)),
        _detailRow('Yearly Cost', currency.format(sub.monthlyAmount * 12)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(ctx); _editSubscription(sub); }, icon: const Icon(Icons.edit), label: const Text('Edit'))),
          const SizedBox(width: 12),
          Expanded(child: FilledButton.icon(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.check), label: const Text('Done'))),
        ]),
      ]),
    ));
  }

  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: Colors.grey.shade600)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]));
  }

  void _editSubscription(Subscription sub) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddSubscriptionScreen(subscription: sub)));
    if (result != null) {
      widget.onUpdateSubscription?.call(result);
      setState(() {
        final idx = _subscriptions.indexWhere((s) => s.id == sub.id);
        if (idx != -1) _subscriptions[idx] = result;
      });
    }
  }

  Widget _buildServiceLogo(String name, Color color, bool isMobile) {
    final logoUrl = getServiceLogo(name);
    final avatarSize = isMobile ? 36.0 : 44.0;
    final fontSize = isMobile ? 14.0 : 16.0;
    
    if (logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Image.network(
            logoUrl,
            width: avatarSize,
            height: avatarSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: color.withOpacity(0.2),
              child: Text(name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: fontSize)),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: color.withOpacity(0.2),
      child: Text(name[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: fontSize)),
    );
  }

  void _confirmDelete(Subscription sub) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Subscription?'),
      content: Text('Are you sure you want to delete ${sub.name}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () {
          Navigator.pop(ctx);
          widget.onDeleteSubscription?.call(sub.id);
          setState(() {
            _subscriptions.removeWhere((s) => s.id == sub.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${sub.name} deleted 🗡️')));
        }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SubKiller'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()));
            if (result != null) {
              widget.onAddSubscription?.call(result);
              setState(() { _subscriptions.add(result); });
            }
          }),
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: _exportCSV),
          IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), onPressed: widget.onToggleTheme),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 400;
          return Column(children: [
            Padding(padding: EdgeInsets.all(isMobile ? 12 : 16), child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = '')) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
              ),
            )),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
              child: Row(children: [
                ActionChip(avatar: const Icon(Icons.category, size: 18), label: Text(_selectedCategories.isEmpty ? 'Categories' : '${_selectedCategories.length}', style: TextStyle(fontSize: isMobile ? 12 : 14)), onPressed: _showCategoryFilter),
                const SizedBox(width: 8),
                ActionChip(avatar: const Icon(Icons.repeat, size: 18), label: Text(_selectedBillingCycles.isEmpty ? 'Billing' : '${_selectedBillingCycles.length}', style: TextStyle(fontSize: isMobile ? 12 : 14)), onPressed: _showBillingCycleFilter),
                const SizedBox(width: 8),
                if (_selectedCategories.isNotEmpty || _selectedBillingCycles.isNotEmpty) ActionChip(avatar: const Icon(Icons.clear, size: 18), label: const Text('Clear'), onPressed: () => setState(() { _selectedCategories.clear(); _selectedBillingCycles.clear(); })),
              ]),
            ),
            const SizedBox(height: 8),
            Container(width: double.infinity, margin: EdgeInsets.all(isMobile ? 12 : 16), padding: EdgeInsets.all(isMobile ? 16 : 20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.redAccent, Colors.deepOrange]), borderRadius: BorderRadius.circular(16)), child: Column(children: [
              Text('Monthly Spend', style: TextStyle(color: Colors.white70, fontSize: isMobile ? 12 : 14)),
              const SizedBox(height: 4),
              Text(currency.format(totalMonthly), style: TextStyle(color: Colors.white, fontSize: isMobile ? 28 : 36, fontWeight: FontWeight.bold)),
              Text('${currency.format(totalYearly)} / year', style: const TextStyle(color: Colors.white70)),
            ])),
            if (spendingByCategory.isNotEmpty) ...[
              Padding(padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16), child: Text('Spending by Category', style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold))),
              const SizedBox(height: 8),
              SizedBox(height: isMobile ? 70 : 80, child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                itemCount: spendingByCategory.length,
                itemBuilder: (context, index) {
                  final category = spendingByCategory.keys.elementAt(index);
                  final amount = spendingByCategory[category]!;
                  final cardWidth = isMobile ? 100.0 : 120.0;
                  return InkWell(
                    onTap: () => setState(() {
                      if (_selectedCategories.contains(category)) {
                        _selectedCategories.remove(category);
                      } else {
                        _selectedCategories.add(category);
                      }
                    }),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: getCategoryColor(category).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _selectedCategories.contains(category) ? getCategoryColor(category) : getCategoryColor(category).withOpacity(0.3), width: _selectedCategories.contains(category) ? 2 : 1),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(category, style: TextStyle(fontSize: isMobile ? 10 : 12, color: getCategoryColor(category), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(currency.format(amount), style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  );
                },
              )),
              const SizedBox(height: 16),
            ],
            Padding(padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Upcoming', style: TextStyle(fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.bold)),
              Text('${filteredSubscriptions.length}', style: TextStyle(color: Colors.grey.shade600)),
            ])),
            const SizedBox(height: 8),
            Expanded(child: filteredSubscriptions.isEmpty 
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.search_off, size: isMobile ? 48 : 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No subscriptions', style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey.shade600)),
                ])) 
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                  itemCount: filteredSubscriptions.length,
                  itemBuilder: (context, index) {
                    final sub = filteredSubscriptions[index];
                    final catColor = getCategoryColor(sub.category);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _showSubscriptionDetails(sub),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 8 : 12),
                          child: Row(children: [
                            _buildServiceLogo(sub.name, catColor, isMobile),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(sub.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16)),
                              const SizedBox(height: 2),
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: Text(sub.category ?? 'Other', style: TextStyle(fontSize: isMobile ? 10 : 11, color: catColor)),
                                ),
                                const SizedBox(width: 8),
                                Text(sub.daysUntilRenewal == 0 ? 'Due today!' : '${sub.daysUntilRenewal} days', style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade600)),
                              ]),
                            ])),
                            Text(currency.format(sub.amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16)),
                          ]),
                        ),
                      ),
                    );
                  },
                )),
          ]);
        },
      ),
    );
  }
}