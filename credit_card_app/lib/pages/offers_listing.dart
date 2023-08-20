import 'package:flutter/material.dart';
import '../models/credit_card_model.dart';
import '../models/credit_card_response_model.dart';
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
          title: const Text("Kredi Kartı Teklifleri"),
          bottom: const TabBar(
            tabs: [
              Tab(
                key: Key("active_tab"),
                text: "Aktif",
                icon: Icon(Icons.local_activity),
                iconMargin: EdgeInsets.zero,
              ),
              Tab(
                key: Key("passive_tab"),
                text: "Pasif",
                icon: Icon(Icons.local_offer),
                iconMargin: EdgeInsets.zero,
              ),
              Tab(
                key: Key("sponsored_tab"),
                text: "Sponsorlu",
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
          subtitle: Text("Puan: ${offer.rating}"),
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
                GestureDetector(
                  onTap: () {
                    _showFullScreenImage(context, offer.imgUrl);
                  },
                  child: Image.network(
                    offer.imgUrl,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Yıllık Ödeme: ${offer.annualPayment}'),
                Text('Alışveriş Faizi: ${offer.shoppingInterest}'),
                Text('Gecikme Faizi: ${offer.overdueInterest}'),
                Text('Nakit Avans Faizi: ${offer.cashAdvanceInterest}'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _launchURL(offer.url),
                  child: const Text(
                    'Şimdi Başvur',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),
                Text('Aktif: ${offer.active ? 'Evet' : 'Hayır'}'),
                Text('Puan: ${offer.rating}'),
                const SizedBox(height: 10),
                Text('Kampanyalar: ${offer.campaigns.join(', ')}'),
                Text('Kategoriler: ${offer.categories.join(', ')}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Kapat'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // to take full screen height
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
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
