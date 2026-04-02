class Subscription {
  final String id;
  final String name;
  final double amount;
  final String billingCycle;
  final DateTime renewalDate;
  final String? category;
  final String? iconUrl;
  final bool isActive;
  final bool isCancelled;
  final DateTime? lastUsed;

  Subscription({required this.id, required this.name, required this.amount, required this.billingCycle, required this.renewalDate, this.category, this.iconUrl, this.isActive = true, this.isCancelled = false, this.lastUsed});

  Subscription copyWith({String? id, String? name, double? amount, String? billingCycle, DateTime? renewalDate, String? category, String? iconUrl, bool? isActive, bool? isCancelled, DateTime? lastUsed}) {
    return Subscription(id: id ?? this.id, name: name ?? this.name, amount: amount ?? this.amount, billingCycle: billingCycle ?? this.billingCycle, renewalDate: renewalDate ?? this.renewalDate, category: category ?? this.category, iconUrl: iconUrl ?? this.iconUrl, isActive: isActive ?? this.isActive, isCancelled: isCancelled ?? this.isCancelled, lastUsed: lastUsed ?? this.lastUsed);
  }

  double get monthlyAmount {
    switch (billingCycle) {
      case 'yearly': return amount / 12;
      case 'weekly': return amount * 4.33;
      default: return amount;
    }
  }

  int get daysUntilRenewal => renewalDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'amount': amount, 'billing_cycle': billingCycle, 'renewal_date': renewalDate.toIso8601String(), 'category': category, 'is_active': isActive, 'is_cancelled': isCancelled, 'last_used': lastUsed?.toIso8601String()};

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(id: json['id'], name: json['name'], amount: (json['amount'] as num).toDouble(), billingCycle: json['billing_cycle'], renewalDate: DateTime.parse(json['renewal_date']), category: json['category'], isActive: json['is_active'] ?? true, isCancelled: json['is_cancelled'] ?? false, lastUsed: json['last_used'] != null ? DateTime.parse(json['last_used']) : null);
}