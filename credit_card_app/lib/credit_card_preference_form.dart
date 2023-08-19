import 'package:flutter/material.dart';

import 'globals.dart';
import 'models.dart';
import 'offer_listing_screen.dart';
import 'utils.dart';

enum SelectionType { Age, SpendingHabit, Expectation }

class CreditCardPreferenceForm extends StatefulWidget {
  @override
  _CreditCardPreferenceFormState createState() =>
      _CreditCardPreferenceFormState();
}

class _CreditCardPreferenceFormState extends State<CreditCardPreferenceForm> {
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
        leading: _currentPage != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                  setState(() {
                    _currentPage--;
                  });
                },
              )
            : null,
        title: const Text('Credit Card Preference'),
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
            if (_currentPage != 0)
              FloatingActionButton(
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
            else
              const SizedBox(),
            FloatingActionButton(
              heroTag: "next_button",
              child: _currentPage != 2
                  ? const Icon(Icons.arrow_forward)
                  : const Icon(Icons.check),
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

  Widget _buildCard(
    String title,
    Widget content,
  ) {
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

  List<Widget> _createSegmentedButtons(List<String> items,
      Function(String) onSelect, int chunkSize, SelectionType type) {
    List<Widget> buttons = [];

    for (int i = 0; i < items.length; i += chunkSize) {
      List<String> currentChunk = items.sublist(
          i, i + chunkSize > items.length ? items.length : i + chunkSize);

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
                          return isSelected ? Colors.blue : Colors.grey[200]!;
                        } else if (type == SelectionType.SpendingHabit) {
                          return badgeNumber != null
                              ? Colors.blue
                              : Colors.grey[200]!;
                        } else if (type == SelectionType.Expectation) {
                          return badgeNumber != null
                              ? Colors.blue
                              : Colors.grey[200]!;
                        } else {
                          return Colors.grey[200]!;
                        }
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          return badgeNumber != null
                              ? Colors.white
                              : Colors.black;
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
                      backgroundColor: Colors.red,
                      child: Text(
                        badgeNumber.toString(),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
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
        }, 2, SelectionType.Age),
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
        }, 2, SelectionType.SpendingHabit),
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
        }, 2, SelectionType.Expectation),
      ],
    );
  }
}
