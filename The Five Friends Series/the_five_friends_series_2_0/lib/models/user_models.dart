class OwnerUser {
  final String email;
  final String name;
  final String role;
  final String avatarColor;

  const OwnerUser({
    required this.email,
    required this.name,
    required this.role,
    required this.avatarColor,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'role': role,
        'avatarColor': avatarColor,
      };

  factory OwnerUser.fromJson(Map<String, dynamic> json) => OwnerUser(
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        avatarColor: json['avatarColor'] as String? ?? '',
      );
}

class ReaderUser {
  final String id;
  final String name;
  final String email;
  final String? avatarColor;
  final String loginTime;

  const ReaderUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarColor,
    required this.loginTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarColor': avatarColor,
        'loginTime': loginTime,
      };

  factory ReaderUser.fromJson(Map<String, dynamic> json) => ReaderUser(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Reader',
        email: json['email'] as String? ?? '',
        avatarColor: json['avatarColor'] as String?,
        loginTime: json['loginTime'] as String? ?? '',
      );
}

class DeliveryAddress {
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String postalCode;
  final String? notes;

  const DeliveryAddress({
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.postalCode,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'postalCode': postalCode,
        'notes': notes,
      };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        street: json['street'] as String? ?? '',
        city: json['city'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
        notes: json['notes'] as String?,
      );
}

class PurchaseRecord {
  final String id;
  final String storyId;
  final String storyTitle;
  final double amount;
  final String paymentMethod; // 'card' | 'upi' | 'cod'
  final String timestamp;
  final String status; // 'completed' | 'processing' | 'shipped' | 'delivered'
  final DeliveryAddress? deliveryAddress;

  const PurchaseRecord({
    required this.id,
    required this.storyId,
    required this.storyTitle,
    required this.amount,
    required this.paymentMethod,
    required this.timestamp,
    required this.status,
    this.deliveryAddress,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'storyId': storyId,
        'storyTitle': storyTitle,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'timestamp': timestamp,
        'status': status,
        'deliveryAddress': deliveryAddress?.toJson(),
      };

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) => PurchaseRecord(
        id: json['id'] as String? ?? '',
        storyId: json['storyId'] as String? ?? '',
        storyTitle: json['storyTitle'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        paymentMethod: json['paymentMethod'] as String? ?? 'card',
        timestamp: json['timestamp'] as String? ?? '',
        status: json['status'] as String? ?? 'completed',
        deliveryAddress: json['deliveryAddress'] != null
            ? DeliveryAddress.fromJson(json['deliveryAddress'] as Map<String, dynamic>)
            : null,
      );
}
