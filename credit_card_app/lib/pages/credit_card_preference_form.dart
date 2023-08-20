import 'package:flutter/material.dart';
import '../globals.dart';
import '../models/credit_card_response_model.dart';
import 'offers_listing.dart';
import '../utils.dart';

enum SelectionType { Age, SpendingHabit, Expectation }

class CreditCardPreferenceForm extends StatefulWidget {
  const CreditCardPreferenceForm({super.key});

  @override
  CreditCardPreferenceFormState createState() =>
      CreditCardPreferenceFormState();
}

class CreditCardPreferenceFormState extends State<CreditCardPreferenceForm> {
  late PageController _pageController;
  int _currentPage = 0;
  String selectedAge = "";
  List<String> spendingHabitOrder = [];
  List<String> expectationOrder = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kredi Kartı Tercih Formu'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe to next
        children: [
          _buildCard("Yaş Aralığı", _buildAgeSegmentedControl()),
          _buildCard("Harcama Alışkanlıklarınız",
              _buildSpendingHabitsSegmentedControl()),
          _buildCard("Kredi Kartından Beklentileriniz",
              _buildExpectationsSegmentedControl()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _currentPage != 0
                ? FloatingActionButton(
                    heroTag: "back_button",
                    child: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                      setState(() {
                        _currentPage--;
                      });
                    },
                  )
                : const SizedBox(),
            FloatingActionButton(
              heroTag: "next_button",
              child:
                  Icon(_currentPage != 2 ? Icons.arrow_forward : Icons.check),
              onPressed: () async {
                if (_currentPage == 0 && selectedAge.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lütfen yaş aralığını seçiniz."),
                    ),
                  );
                  return;
                } else if (_currentPage == 1 && spendingHabitOrder.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Lütfen harcama alışkanlıklarınızı seçiniz."),
                    ),
                  );
                  return;
                } else if (_currentPage == 2 && expectationOrder.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Lütfen kredi kartından beklentilerinizi seçiniz."),
                    ),
                  );
                  return;
                }

                if (_currentPage != 2) {
                  _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                  setState(() {
                    _currentPage++;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kredi kartı teklifleri yükleniyor..."),
                      duration: Duration(seconds: 10),
                    ),
                  );
                  CreditCardResponse creditCardResponse =
                      await fetchCreditCardOffers(
                    age: ageRange.indexOf(selectedAge) + 1,
                    spendingHabitsOrder: spendingHabitOrder
                        .map((habit) => spendingHabits.indexOf(habit) + 1)
                        .toList(),
                    creditCardExpectationsOrder: expectationOrder
                        .map((expectation) =>
                            creditCardExpectations.indexOf(expectation) + 1)
                        .toList(),
                  );

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfferListingScreen(
                        cardResponse: creditCardResponse,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _createSegmentedButtons(
      List<String> items, Function(String) onSelect, SelectionType type) {
    List<Widget> buttons = [];

    for (int i = 0; i < items.length; i += 2) {
      List<String> currentChunk =
          items.sublist(i, i + 2 > items.length ? items.length : i + 2);

      buttons.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: currentChunk.map((item) {
            int? badgeNumber;
            bool isSelected = selectedAge == item;
            switch (type) {
              case SelectionType.SpendingHabit:
                final index = spendingHabitOrder.indexOf(item);
                if (index >= 0) {
                  badgeNumber = index + 1;
                }
                break;
              case SelectionType.Expectation:
                final index = expectationOrder.indexOf(item);
                if (index >= 0) {
                  badgeNumber = index + 1;
                }
                break;
              case SelectionType.Age:
                isSelected = selectedAge == item;
                break;
              default:
                break;
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (type == SelectionType.Age) {
                          return isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer;
                        } else if (type == SelectionType.SpendingHabit) {
                          return badgeNumber != null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer;
                        } else if (type == SelectionType.Expectation) {
                          return badgeNumber != null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer;
                        } else {
                          return Theme.of(context).colorScheme.primaryContainer;
                        }
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (type == SelectionType.Age) {
                            return isSelected ? Colors.white : Colors.black;
                          } else if (type == SelectionType.SpendingHabit) {
                            return badgeNumber != null
                                ? Colors.white
                                : Colors.black;
                          } else if (type == SelectionType.Expectation) {
                            return badgeNumber != null
                                ? Colors.white
                                : Colors.black;
                          } else {
                            return Colors.white;
                          }
                        },
                      ),
                    ),
                    onPressed: () => onSelect(item),
                    child: Text(
                      item,
                      softWrap: true,
                    ),
                  ),
                ),
                if (badgeNumber != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      child: Text(
                        badgeNumber.toString(),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      );
      buttons.add(const SizedBox(height: 8));
    }

    return buttons;
  }

  Widget _buildAgeSegmentedControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ..._createSegmentedButtons(ageRange, (String age) {
          setState(() {
            selectedAge = age;
          });
        }, SelectionType.Age),
      ],
    );
  }

  Widget _buildSpendingHabitsSegmentedControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ..._createSegmentedButtons(spendingHabits, (String habit) {
          setState(() {
            if (spendingHabitOrder.contains(habit)) {
              spendingHabitOrder.remove(habit);
            } else {
              spendingHabitOrder.add(habit);
            }
          });
        }, SelectionType.SpendingHabit),
      ],
    );
  }

  Widget _buildExpectationsSegmentedControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ..._createSegmentedButtons(creditCardExpectations,
            (String expectation) {
          setState(() {
            if (expectationOrder.contains(expectation)) {
              expectationOrder.remove(expectation);
            } else {
              expectationOrder.add(expectation);
            }
          });
        }, SelectionType.Expectation),
      ],
    );
  }
}
