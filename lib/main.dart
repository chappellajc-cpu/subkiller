import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/usage_screen.dart';
import 'screens/reminder_settings_screen.dart';
import 'screens/add_subscription_screen.dart';
import 'models/subscription.dart';

void main() {
  runApp(const SubKillerApp());
}

class SubKillerApp extends StatefulWidget {
  const SubKillerApp({super.key});
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
      home: HomeScreen(onToggleTheme: toggleTheme),
      routes: {
        '/add': (context) => const AddSubscriptionScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Subscription> _subscriptions = [
    Subscription(id: '1', name: 'Netflix', amount: 15.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 5)), lastUsed: DateTime.now().add(const Duration(days: -45)), category: 'Entertainment'),
    Subscription(id: '2', name: 'Spotify', amount: 10.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 12)), lastUsed: DateTime.now().add(const Duration(days: -2)), category: 'Music'),
    Subscription(id: '3', name: 'Amazon Prime', amount: 8.99, billingCycle: 'monthly', renewalDate: DateTime.now().add(const Duration(days: 20)), lastUsed: DateTime.now().add(const Duration(days: -60)), category: 'Shopping'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(subscriptions: _subscriptions, onToggleTheme: widget.onToggleTheme),
          CalendarScreen(subscriptions: _subscriptions),
          UsageScreen(subscriptions: _subscriptions, onMarkUsed: (sub) {
            setState(() {
              final idx = _subscriptions.indexWhere((s) => s.id == sub.id);
              if (idx != -1) _subscriptions[idx] = sub;
            });
          }),
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
