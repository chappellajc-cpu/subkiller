class Subscription {
  final String id;
  final String name;
  final double amount;
  final String billingCycle;
  final DateTime renewalDate;
  final String? category;
  final String? iconUrl;
  final bool isActive;
  final DateTime? lastUsed;

  Subscription({required this.id, required this.name, required this.amount, required this.billingCycle, required this.renewalDate, this.category, this.iconUrl, this.isActive = true, this.lastUsed});

  double get monthlyAmount {
    switch (billingCycle) {
      case 'yearly': return amount / 12;
      case 'weekly': return amount * 4.33;
      default: return amount;
    }
  }

  int get daysUntilRenewal => renewalDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'amount': amount, 'billing_cycle': billingCycle, 'renewal_date': renewalDate.toIso8601String(), 'category': category};

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(id: json['id'], name: json['name'], amount: (json['amount'] as num).toDouble(), billingCycle: json['billing_cycle'], renewalDate: DateTime.parse(json['renewal_date']));
}
