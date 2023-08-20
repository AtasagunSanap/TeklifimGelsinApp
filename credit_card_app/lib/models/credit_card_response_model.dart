import 'credit_card_model.dart';

class CreditCardResponse {
  final List<CreditCard> sponsoredOffers;
  final List<CreditCard> activeOffers;
  final List<CreditCard> passiveOffers;
  final int? id;
  final String? createdAt;

  CreditCardResponse({
    required this.sponsoredOffers,
    required this.activeOffers,
    required this.passiveOffers,
    this.id,
    this.createdAt,
  });

  factory CreditCardResponse.fromJson(Map<String, dynamic> json) {
    return CreditCardResponse(
      sponsoredOffers: (json['sponsored_offers'] as List)
          .map((e) => CreditCard.fromJson(e))
          .toList(),
      activeOffers: (json['active_offers'] as List)
          .map((e) => CreditCard.fromJson(e))
          .toList(),
      passiveOffers: (json['passive_offers'] as List)
          .map((e) => CreditCard.fromJson(e))
          .toList(),
      id: json['id'],
      createdAt: json['created_at'],
    );
  }
}
