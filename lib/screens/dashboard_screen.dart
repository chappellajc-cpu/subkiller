import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:intl/intl.dart'; 

import '../models/subscription.dart';
import 'add_subscription_screen.dart'; 

// Global variable to hold currency preference, loaded once in main.dart
String globalSelectedCurrencyCode = 'USD'; 

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
  
  String _currentCurrencyCode = 'USD';

  static const List<Map<String, String>> _availableCurrencies = [
    {'name': 'US Dollar', 'code': 'USD', 'symbol': '\$'},
    {'name': 'Euro', 'code': 'EUR', 'symbol': '€'},
    {'name': 'Pound Sterling', 'code': 'GBP', 'symbol': '£'},
    {'name': 'Japanese Yen', 'code': 'JPY', 'symbol': '¥'},
    {'name': 'Canadian Dollar', 'code': 'CAD', 'symbol': '\$'},
    {'name': 'Australian Dollar', 'code': 'AUD', 'symbol': '\$'},
  ];

  @override
  void initState() {
    super.initState();
    _subscriptions = widget.subscriptions ?? _loadSampleData();
    _loadCurrencyPreference(); 
  }

  Future<void> _loadCurrencyPreference() async {
    setState(() {
      _currentCurrencyCode = globalSelectedCurrencyCode; 
    });
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
    'Entertainment': Colors.purple,
    'Music': Colors.green,
    'Productivity': Colors.blue,
    'Cloud Storage': Colors.cyan,
    'Gaming': Colors.red,
    'News': Colors.orange,
    'Fitness': Colors.teal,
    'Shopping': Colors.pink,
    'Health': Colors.green,
    'Other': Colors.grey,
  };

  static const Map<String, String> serviceDomains = {
'netflix': 'netflix.com', 'spotify': 'spotify.com', 'amazon prime': 'amazon.com', 'amazonprime': 'amazon.com',
    'amazon': 'amazon.com', 'prime video': 'primevideo.com', 'apple': 'apple.com', 'apple music': 'music.apple.com',
    'apple tv': 'tv.apple.com', 'disney': 'disneyplus.com', 'disney plus': 'disneyplus.com', 'hbo': 'hbomax.com',
    'hbo max': 'max.com', 
    'youtube': 'youtube.com', 'youtube premium': 'youtube.com', 'microsoft': 'microsoft.com',
    'google': 'google.com', 'dropbox': 'dropbox.com', 'icloud': 'icloud.com', 'adobe': 'adobe.com',
    'notion': 'notion.so', 'slack': 'slack.com', 'zoom': 'zoom.us', 'nordvpn': 'nordvpn.com',
    'gym': 'gymshark.com', 'fitness': 'gymshark.com', 'amazon prime video': 'primevideo.com', 'samsung': 'samsung.com',
    'sky': 'sky.com', 'now tv': 'nowtv.com', 'bt': 'bt.com', 'virgin': 'virginmedia.com',
    'barclays': 'barclays.co.uk', 'monzo': 'monzo.com', 'revolut': 'revolut.com', 'paypal': 'paypal.com',
    'wine': 'winedirect.com', 'kindle': 'amazon.co.uk', 'audible': 'audible.co.uk', 'duolingo': 'duolingo.com',
    'chatgpt': 'chatgpt.com', 'copilot': 'copilot.microsoft.com', 'clash': 'clashofclans.com', 'candy crush': 'candycrush.com',
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
      return 'https://www.google.com/s2/favicons?domain=' + Uri.encodeComponent(domain) + '&sz=64';
    }
    return null;
  }

  static Color getCategoryColor(String? category) => categoryColors[category] ?? Colors.grey;

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
    ]
;
  }

  double get totalMonthly {
final currencySymbol = _availableCurrencies.firstWhere(
      (c) => c['code'] == _currentCurrencyCode,
      orElse: () => {'symbol': '\$'},
    )['symbol']!;
    final currencyFormat = NumberFormat.currency(locale: Intl.defaultLocale, symbol: currencySymbol);
    return filteredSubscriptions.fold(0.0, (sum, sub) => sum + sub.monthlyAmount);
  }
  
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
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(c);
              } else {
                  _selectedCategories.remove(c);
              }
            });
          },
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
          onSelected: (selected) { 
            setState(() {
              if (selected) {
                _selectedBillingCycles.add(c);
              } else {
                _selectedBillingCycles.remove(c);
              }
            });
          },
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
    final currencySymbol = _availableCurrencies.firstWhere(
      (c) => c['code'] == _currentCurrencyCode, 
      orElse: () => {'symbol': '\$'},
    )['symbol']!;
    final currencyFormat = NumberFormat.currency(locale: Intl.defaultLocale, symbol: currencySymbol);
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
        _detailRow('Amount', currencyFormat.format(sub.amount)),
        _detailRow('Billing Cycle', sub.billingCycle == 'monthly' ? 'Monthly' : sub.billingCycle == 'yearly' ? 'Yearly' : 'Weekly'),
        _detailRow('Category', sub.category ?? 'Other'),
        _detailRow('Renewal Date', DateFormat.yMMMd().format(sub.renewalDate)),
        _detailRow('Next Payment', '${sub.daysUntilRenewal} days'),
        _detailRow('Monthly Cost', currencyFormat.format(sub.monthlyAmount)),
        _detailRow('Yearly Cost', currencyFormat.format(sub.monthlyAmount * 12)),
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSubscriptionScreen(subscription: sub)),
    );
    if (result != null && result is Subscription) { 
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
    
    if (logoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          logoUrl,
          width: avatarSize,
          height: avatarSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => CircleAvatar( 
            radius: avatarSize / 2,
            backgroundColor: color.withOpacity(0.2),
            child: Text(name.isNotEmpty ? name[0] : '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isMobile ? 14.0 : 16.0)),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: color.withOpacity(0.2),
      child: Text(name.isNotEmpty ? name[0] : '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isMobile ? 14.0 : 16.0)),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${sub.name} deleted 🗡')));
        }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    
    final currencySymbol = _availableCurrencies.firstWhere(
      (c) => c['code'] == _currentCurrencyCode,
      orElse: () => {'symbol': '\$'},
    )['symbol']!;

    final currencyFormat = NumberFormat.currency(
      locale: Intl.defaultLocale, 
      symbol: currencySymbol, 
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
return
Scaffold(
      appBar: AppBar(
        title: const Text('SubKiller Dashboard'), 
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SubscriptionSearchDelegate(
                  subscriptions: _subscriptions, 
                  onQueryChanged: (query) {
                    setState(() {
                      _searchQuery = query; 
                    });
                  },
                  availableCurrencies: _availableCurrencies,
                  globalSelectedCurrencyCode: _currentCurrencyCode,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme, 
          ),
           IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showCategoryFilter(); 
              _showBillingCycleFilter(); 
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly Total', style: TextStyle(color: Colors.grey.shade600)),
                        Text(
                          currencyFormat.format(totalMonthly), 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Yearly Total', style: TextStyle(color: Colors.grey.shade600)),
                        Text(
                          currencyFormat.format(totalYearly), 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1), 

          Expanded(
            child: filteredSubscriptions.isEmpty
                ? const Center(child: Text('No subscriptions found. Add one to get started!', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filteredSubscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = filteredSubscriptions[index];
                      final categoryColor = getCategoryColor(sub.category); 
                      final isMobileLayout = isMobile; 

                      return ListTile(
                        leading: _buildServiceLogo(sub.name, categoryColor, isMobileLayout), 
                        title: Text(sub.name, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${sub.billingCycle == 'monthly' ? 'Monthly' : sub.billingCycle == 'yearly' ? 'Yearly' : 'Weekly'} - ${DateFormat.yMMMd().format(sub.renewalDate)}',
                            ),
                            Text('Est. Monthly Cost: ${currencyFormat.format(sub.monthlyAmount)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editSubscription(sub),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(sub),
                            ),
                          ],
                        ),
                        onTap: () => _showSubscriptionDetails(sub), 
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
          );
          if (result != null && result is Subscription) {
            widget.onAddSubscription?.call(result);
            setState(() {
              _subscriptions.add(result);
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${result.name} added! 🎉')));
          }
        },
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

// --- Search Delegate for the AppBar Search Icon ---
class SubscriptionSearchDelegate extends SearchDelegate {
  final List<Subscription> subscriptions;
  final Function(String) onQueryChanged;
  final List<Map<String, String>> availableCurrencies;
  final String globalSelectedCurrencyCode;

  SubscriptionSearchDelegate({
    required this.subscriptions,
    required this.onQueryChanged,
    required this.availableCurrencies,
    required this.globalSelectedCurrencyCode,
  });

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

 @override
 Widget buildResults(BuildContext context) {
final results = subscriptions.where((sub) =>
 sub.name.toLowerCase().contains(query.toLowerCase()) ||
 (sub.category?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();
    
 return results.isEmpty
 ? const Center(child: Text('No subscriptions found matching your search.'))
 : ListView.builder(
 itemCount: results.length,
 itemBuilder: (context, index) {
 final sub = results[index];
 final currencySymbol = availableCurrencies.firstWhere(
 (c) => c['code'] == globalSelectedCurrencyCode, 
 orElse: () => {'symbol': '\$'},
 )['symbol']!;
 final currencyFormat = NumberFormat.currency(locale: Intl.defaultLocale, symbol: currencySymbol);

 return ListTile(
 title: Text(sub.name),
 subtitle: Text('${sub.billingCycle == 'monthly' ? 'Monthly' : sub.billingCycle == 'yearly' ? 'Yearly' : 'Weekly'} - ${currencyFormat.format(sub.monthlyAmount)}'),
 onTap: () {
 close(context, sub.name); 
 },
 );
 },
 );
 }

 @override
 Widget buildSuggestions(BuildContext context) {
 final suggestionList = query.isEmpty
 ? [] 
 : subscriptions.where((sub) =>
 sub.name.toLowerCase().contains(query.toLowerCase()) ||
 (sub.category?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();

 return ListView.builder(
 itemCount: suggestionList.length,
 itemBuilder: (context, index) {
 final sub = suggestionList[index];
 final currencySymbol = availableCurrencies.firstWhere(
 (c) => c['code'] == globalSelectedCurrencyCode, 
 orElse: () => {'symbol': '\$'},
 )['symbol']!;
 final currencyFormat = NumberFormat.currency(locale: Intl.defaultLocale, symbol: currencySymbol);
 
 return ListTile(
 title: Text(sub.name),
 subtitle: Text('${sub.billingCycle == 'monthly' ? 'Monthly' : sub.billingCycle == 'yearly' ? 'Yearly' : 'Weekly'} - ${currencyFormat.format(sub.monthlyAmount)}'),
 onTap: () {
 query = sub.name; 
 onQueryChanged(sub.name); 
 showResults(context); 
 },
 );
 },
 );
 }
}

