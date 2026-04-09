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
