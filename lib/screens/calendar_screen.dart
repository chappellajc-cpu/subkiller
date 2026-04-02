import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class CalendarScreen extends StatefulWidget {
  final List<Subscription> subscriptions;
  const CalendarScreen({super.key, required this.subscriptions});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1))),
          Text(DateFormat.yMMMM().format(_selectedMonth), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1))),
        ])),
        Expanded(child: GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1), itemCount: 42, itemBuilder: (context, index) {
          final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
          final dayOffset = firstDay.weekday % 7;
          final day = index - dayOffset + 1;
          if (day < 1 || day > DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day) return const SizedBox();
          final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
          final hasRenewal = _getRenewalsForDay(date).isNotEmpty;
          final isSelected = _selectedDay?.day == day && _selectedDay?.month == _selectedMonth.month && _selectedDay?.year == _selectedMonth.year;
          return GestureDetector(onTap: () => setState(() => _selectedDay = date), child: Container(margin: const EdgeInsets.all(2), decoration: BoxDecoration(color: hasRenewal ? Colors.redAccent.withOpacity(0.3) : isSelected ? Colors.redAccent : null, borderRadius: BorderRadius.circular(8), border: isSelected ? Border.all(color: Colors.redAccent, width: 2) : null), child: Center(child: Text('$day', style: TextStyle(fontWeight: hasRenewal ? FontWeight.bold : null, color: isSelected ? Colors.white : null)))));
        })),
        if (_selectedDay != null) ...[const Divider(), Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat.yMMMEd().format(_selectedDay!), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._getRenewalsForDay(_selectedDay!).map((sub) => ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: Colors.redAccent.withOpacity(0.1), child: Text(sub.name[0], style: const TextStyle(color: Colors.redAccent))), title: Text(sub.name), trailing: Text('\$${sub.amount.toStringAsFixed(2)}'))),
          if (_getRenewalsForDay(_selectedDay!).isEmpty) const Text('No renewals', style: TextStyle(color: Colors.grey)),
        ]))],
      ]),
    );
  }

  List<Subscription> _getRenewalsForDay(DateTime day) => widget.subscriptions.where((sub) { final next = _getNextRenewalDate(sub); return next.year == day.year && next.month == day.month && next.day == day.day; }).toList();

  DateTime _getNextRenewalDate(Subscription sub) {
    var date = sub.renewalDate;

    while (date.isBefore(DateTime.now())) {
      switch (sub.billingCycle) {
        case 'yearly': date = DateTime(date.year + 1, date.month, date.day); break;
        case 'monthly': date = DateTime(date.year, date.month + 1, date.day); break;
        case 'weekly': date = date.add(const Duration(days: 7)); break;
      }
    }
    return date;
  }
}