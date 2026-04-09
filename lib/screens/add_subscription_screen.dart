import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming Subscription model is defined elsewhere, e.g., in ../models/subscription.dart
import '../models/subscription.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;
  final String initialCurrencyCode;

  const AddSubscriptionScreen({
    super.key,
    this.subscription,
    this.initialCurrencyCode = 'USD',
  });

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _renewalDateController;
  late String _selectedBillingCycle = 'monthly';
  String? _selectedCategory;
  DateTime? _selectedRenewalDate;
  String _selectedCurrencyCode = 'USD'; // Initialize currency code

  // Currency Selection
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
    _nameController = TextEditingController(text: widget.subscription?.name ?? '');
    _amountController = TextEditingController(text: widget.subscription?.amount.toString() ?? '');
    _renewalDateController = TextEditingController(text: widget.subscription?.renewalDate != null ? DateFormat.yMMMd().format(widget.subscription!.renewalDate) : '');
    _selectedBillingCycle = widget.subscription?.billingCycle ?? 'monthly';
    _selectedCategory = widget.subscription?.category;
    _selectedRenewalDate = widget.subscription?.renewalDate;
    
    // Load currency preference on init
    _loadCurrencyPreference(); 
  }

  // Load currency preference from SharedPreferences
  Future<void> _loadCurrencyPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString('selected_currency') ?? widget.initialCurrencyCode;
    setState(() {
      _selectedCurrencyCode = savedCurrency;
    });
  }

  // Save currency preference to SharedPreferences
  Future<void> _saveCurrencyPreference(String currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', currencyCode);
    setState(() { 
      _selectedCurrencyCode = currencyCode;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _renewalDateController.dispose();
    super.dispose();
  }

  Future<void> _selectRenewalDate(BuildContext context) async {
final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedRenewalDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedRenewalDate) {
      setState(() {
        _selectedRenewalDate = picked;
        _renewalDateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  // Helper to get full currency name from code for dropdown display
  String countryCodeToName(String code) {
    switch (code) {
      case 'USD': return 'US Dollar';
      case 'EUR': return 'Euro';
      case 'GBP': return 'Pound Sterling';
      case 'JPY': return 'Japanese Yen';
      case 'CAD': return 'Canadian Dollar';
      case 'AUD': return 'Australian Dollar';
      default: return code; // Fallback to code if name not found
    }
  }

  void _saveSubscription() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final double amount = double.parse(_amountController.text);
      
      // Save the selected currency code to SharedPreferences
      _saveCurrencyPreference(_selectedCurrencyCode);

      final newSubscription = Subscription(
        id: widget.subscription?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        amount: amount,
        billingCycle: _selectedBillingCycle,
        renewalDate: _selectedRenewalDate!,
        category: _selectedCategory,
        // iconUrl is usually fetched or determined elsewhere, not directly input here
        // For now, let's set it to null or fetch based on name if needed later
        iconUrl: null, 
        isActive: true, // Default to active
        isCancelled: false, // Default to not cancelled
        lastUsed: DateTime.now(), // Or based on business logic
      );

      if (widget.subscription == null) {
        // Add new subscription logic (e.g., using a callback)
        // For now, just print and pop
        print('New Subscription Saved: ${newSubscription.name}');
        Navigator.of(context).pop(newSubscription); // Pop with the new subscription data
      } else {
        // Update existing subscription logic
        print('Subscription Updated: ${newSubscription.name}');
        Navigator.of(context).pop(newSubscription); // Pop with the updated subscription data
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Find the currency symbol based on the selected currency code
    final currencySymbol = _availableCurrencies.firstWhere(
      (c) => c['code'] == _selectedCurrencyCode,
      orElse: () => {'symbol': '\$'}, // Default to '$' if not found
    )['symbol']!;
return
Scaffold(
      appBar: AppBar(
        title: Text(widget.subscription == null ? 'Add Subscription' : 'Edit Subscription'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subscription Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Subscription Name',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    // Use the dynamically found currency symbol
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        currencySymbol, // Display the selected currency symbol
                        style: TextStyle(fontSize: isDarkMode ? 16 : 14, color: isDarkMode ? Colors.white70 : Colors.black54, height: 1.8),
                      ),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an amount';
                    if (double.tryParse(value) == null) return 'Please enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Billing Cycle Dropdown
                Row(
                  children: [
                    const Icon(Icons.repeat, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBillingCycle,
                        items: ['monthly', 'yearly', 'weekly'].map((cycle) {
                          return DropdownMenuItem(
                            value: cycle,
                            child: Text(cycle == 'monthly' ? 'Monthly' : cycle == 'yearly' ? 'Yearly' : 'Weekly'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBillingCycle = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Billing Cycle',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                        ),
                      ),
 ),
                  ],
),
                const SizedBox(height: 16),

                // Category Selection
                Row(
                  children: [
                    const Icon(Icons.category, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        hint: const Text('Category'),
                        items: ['Entertainment', 'Music', 'Productivity', 'Cloud Storage', 'Gaming', 'News', 'Fitness', 'Shopping', 'Health', 'Other'].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        decoration: InputDecoration(
                           labelText: 'Category',
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                           filled: true,
                           fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Renewal Date Picker
                TextFormField(
                  controller: _renewalDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Renewal Date',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  ),
                  onTap: () => _selectRenewalDate(context), // Call the function correctly
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please select a renewal date';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Currency Selection Dropdown
Row(
                  children: [
                    const Icon(Icons.money, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCurrencyCode, // Use the code here
                        items: _availableCurrencies.map((currency) {
                          return DropdownMenuItem<String>(
                            value: currency['code']!, // Value is the code
                            // Display name with symbol for better user experience
                            child: Text('${countryCodeToName(currency['code']!)} (${currency['symbol']})'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCurrencyCode = newValue;
                              _saveCurrencyPreference(_selectedCurrencyCode); // Save preference when changed
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveSubscription,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
