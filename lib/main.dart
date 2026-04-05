import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/dashboard_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/usage_screen.dart';
import 'screens/reminder_settings_screen.dart';
import 'models/subscription.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(SubKillerApp(prefs: prefs));
}

class SubKillerApp extends StatefulWidget {
  final SharedPreferences prefs;
  const SubKillerApp({super.key, required this.prefs});
  @override
  State<SubKillerApp> createState() => _SubKillerAppState();
}

class _SubKillerAppState extends State<SubKillerApp> {
  ThemeMode _themeMode = ThemeMode.system;
  
  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubKiller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomeScreen(prefs: widget.prefs, onToggleTheme: toggleTheme),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.prefs, required this.onToggleTheme});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Subscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    final data = widget.prefs.getString('subscriptions');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        _subscriptions = jsonList.map((e) => Subscription.fromJson(e)).toList();
      });
    } else {
      setState(() {
        _subscriptions = [
          Subscription(id: '1', name: 'Netflix', amount: 15.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 5)), lastUsed: DateTime.now().add(const Duration(days: -45)), category: 'Entertainment'),
          Subscription(id: '2', name: 'Spotify', amount: 10.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 12)), lastUsed: DateTime.now().add(const Duration(days: -2)), category: 'Music'),
          Subscription(id: '3', name: 'Amazon Prime', amount: 8.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 20)), lastUsed: DateTime.now().add(const Duration(days: -60)), category: 'Shopping'),
        ];
      });
    }
  }

  Future<void> _saveSubscriptions() async {
    final data = jsonEncode(_subscriptions.map((e) => e.toJson()).toList());
    await widget.prefs.setString('subscriptions', data);
  }

  Future<void> _addSubscription(Subscription sub) async {
    setState(() {
      _subscriptions.add(sub);
    });
    await _saveSubscriptions();
  }

  Future<void> _updateSubscription(Subscription sub) async {
    setState(() {
      final idx = _subscriptions.indexWhere((s) => s.id == sub.id);
      if (idx != -1) _subscriptions[idx] = sub;
    });
    await _saveSubscriptions();
  }

  Future<void> _deleteSubscription(String id) async {
    setState(() {
      _subscriptions.removeWhere((s) => s.id == id);
    });
    await _saveSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            subscriptions: _subscriptions, 
            onToggleTheme: widget.onToggleTheme,
            onAddSubscription: _addSubscription,
            onUpdateSubscription: _updateSubscription,
            onDeleteSubscription: _deleteSubscription,
          ),
          CalendarScreen(subscriptions: _subscriptions),
          UsageScreen(
            subscriptions: _subscriptions, 
            onMarkUsed: _updateSubscription,
            onCancelSubscription: _updateSubscription,
          ),
          ReminderSettingsScreen(subscriptions: _subscriptions),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Usage'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Reminders'),
        ],
      ),
    );
  }
}