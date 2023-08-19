import 'package:flutter/material.dart';
import 'models.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferListingScreen extends StatelessWidget {
  final CreditCardResponse cardResponse;

  const OfferListingScreen({Key? key, required this.cardResponse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Credit Card Offers"),
          bottom: const TabBar(
            tabs: [
              Tab(
                key: Key("active_tab"),
                text: "Active",
                icon: Icon(Icons.local_activity),
                iconMargin: EdgeInsets.zero,
              ),
              Tab(
                key: Key("passive_tab"),
                text: "Passive",
                icon: Icon(Icons.local_offer),
                iconMargin: EdgeInsets.zero,
              ),
              Tab(
                key: Key("sponsored_tab"),
                text: "Sponsored",
                icon: Icon(Icons.star),
                iconMargin: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCardList(cardResponse.activeOffers),
            _buildCardList(cardResponse.passiveOffers),
            _buildCardList(cardResponse.sponsoredOffers),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(List<CreditCard> offers) {
    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return ListTile(
          leading: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                offer.imgUrl,
                fit: BoxFit.cover,
                width: 50, // Adjust the size as needed
                height: 50, // Adjust the size as needed
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
          title: Text(offer.cardName),
          subtitle: Text("Rating: ${offer.rating}"),
          onTap: () => _showDetailsDialog(context, offer),
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, CreditCard offer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(offer.cardName),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.network(
                  offer.imgUrl,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 10),
                Text('Annual Payment: ${offer.annualPayment}'),
                Text('Shopping Interest: ${offer.shoppingInterest}'),
                Text('Overdue Interest: ${offer.overdueInterest}'),
                Text('Cash Advance Interest: ${offer.cashAdvanceInterest}'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _launchURL(offer.url),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),
                Text('Active: ${offer.active ? 'Yes' : 'No'}'),
                Text('Rating: ${offer.rating}'),
                const SizedBox(height: 10),
                Text('Campaigns: ${offer.campaigns.join(', ')}'),
                Text('Categories: ${offer.categories.join(', ')}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
