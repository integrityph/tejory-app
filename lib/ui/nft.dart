import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NFTPage extends StatelessWidget {
  NFTPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          child: new InkWell(
              child: ListTile(
                leading: Image(
                  image: AssetImage('assets/xrp.png'),
                ),
                title: Text('NFT 1'),
              ),
              onTap: () {
                launchUrl(Uri.parse(
                    'https://stackoverflow.com/questions/43583411/how-to-create-a-hyperlink-in-flutter-widget'));
              }),
        ),
        ListTile(
          leading: Image(image: AssetImage('assets/background/bg1.png')),
          title: Text('NFT 2'),
        ),
        Card(
          child: ListTile(
            leading: Image(image: AssetImage('assets/nft.jpg')),
            title: Text('NFT 3'),
          ),
        )
      ],
    );
  }
}
