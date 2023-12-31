import 'dart:convert';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'models/credit_card_response_model.dart';

List<int> _generateReversedFibonacci(int length) {
  if (length <= 0) return [];

  if (length == 1) return [1];

  List<int> sequence = [1, 1];
  for (int i = 2; i < length; i++) {
    sequence.add(sequence[i - 1] + sequence[i - 2]);
  }
  return sequence.reversed.toList();
}

Future<CreditCardResponse> fetchCreditCardOffers({
  required int age,
  required List<int> spendingHabitsOrder,
  required List<int> creditCardExpectationsOrder,
}) async {
  // generate spending fibonacci
  List<int> spendingFibSequence =
      _generateReversedFibonacci(spendingHabits.length);
  Map<String, int> spendingOrderFib = {};
  for (int i = 0; i < spendingHabits.length; i++) {
    String? option = allOptions[spendingHabits[i]];
    if (option == null) throw Exception('Invalid option');
    spendingOrderFib[option] = 1;
  }
  for (int i = 0; i < spendingHabitsOrder.length; i++) {
    String? option = allOptions[spendingHabits[spendingHabitsOrder[i] - 1]];
    if (option == null) throw Exception('Invalid option');
    spendingOrderFib[option] = spendingFibSequence[i];
  }

  // generate credit card fibonacci
  List<int> creditCardFibSequence =
      _generateReversedFibonacci(creditCardExpectations.length);
  Map<String, int> creditCardOrderFib = {};
  for (int i = 0; i < creditCardExpectations.length; i++) {
    String? option = allOptions[creditCardExpectations[i]];
    if (option == null) throw Exception('Invalid option');
    creditCardOrderFib[option] = 1;
  }
  for (int i = 0; i < creditCardExpectationsOrder.length; i++) {
    String? option =
        allOptions[creditCardExpectations[creditCardExpectationsOrder[i] - 1]];
    if (option == null) throw Exception('Invalid option');
    creditCardOrderFib[option] = creditCardFibSequence[i];
  }

  // merge two maps and age
  Map<String, dynamic> data = {
    'age': age,
    ...spendingOrderFib,
    ...creditCardOrderFib,
  };

  final response = await http.post(
    Uri.parse('${websiteUrl}api/prep/createCardPost'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final CreditCardResponse cardResponse =
        CreditCardResponse.fromJson(jsonResponse);
    return cardResponse;
  } else {
    throw Exception('Failed to load offers');
  }
}
