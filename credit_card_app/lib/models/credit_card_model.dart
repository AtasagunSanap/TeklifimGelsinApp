class CreditCard {
  final int cardId;
  final int bankId;
  final String cardName;
  final double annualPayment;
  final double shoppingInterest;
  final double overdueInterest;
  final double cashAdvanceInterest;
  final String imgUrl;
  final String url;
  final int sponsored;
  final bool active;
  final List<dynamic> campaigns;
  final List<String> categories;
  final double rating;

  CreditCard({
    required this.cardId,
    required this.bankId,
    required this.cardName,
    required this.annualPayment,
    required this.shoppingInterest,
    required this.overdueInterest,
    required this.cashAdvanceInterest,
    required this.imgUrl,
    required this.url,
    required this.sponsored,
    required this.active,
    required this.campaigns,
    required this.categories,
    required this.rating,
  });

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      cardId: json['card_id'],
      bankId: json['bank_id'],
      cardName: json['card_name'],
      annualPayment: json['annual_payment'].toDouble(),
      shoppingInterest: json['shopping_interest'].toDouble(),
      overdueInterest: json['overdue_interest'].toDouble(),
      cashAdvanceInterest: json['cash_advance_interest'].toDouble(),
      imgUrl: json['img_url'],
      url: json['url'],
      sponsored: json['sponsored'],
      active: json['active'],
      campaigns: json['campaigns'],
      categories: List<String>.from(json['categories']),
      rating: json['rating'].toDouble(),
    );
  }
}
