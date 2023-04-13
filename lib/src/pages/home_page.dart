import 'dart:developer';

import 'package:chatgpt/constants/colors.dart';
import 'package:chatgpt/network/admob_service_helper.dart';
import 'package:chatgpt/src/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static AdRequest request = const AdRequest(nonPersonalizedAds: true);

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  final BannerAd myBanner = BannerAd(
    adUnitId: AdMobService.bannerAdUnitId ?? '',
    size: AdSize.fullBanner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId ?? '',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            log('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            log('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      log('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    super.initState();
    myBanner.load();
    _createInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chatgpt',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF292B4D),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            buttonWidget('Ingresa al chatbot aquí', () {
              // _showInterstitialAd();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatPage(),
                ),
              );
            }, true),
          ],
        ),
      ),
      bottomNavigationBar: Container(
          color: const Color(0xFF292B4D),
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Desarrollado por ",
                  style: TextStyle(color: Colors.white)),
              InkWell(
                onTap: () {
                  _launchUrl(Uri.parse(
                    'https://brita.mx/',
                  ));
                },
                child: const Text(
                  "Brita Inteligencia Artificial",
                  style: TextStyle(
                    color: Color.fromARGB(255, 218, 96, 240),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget buttonWidget(String text, VoidCallback onTap, bool imageBtn) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // color: redColor,
        decoration: BoxDecoration(
          color: redColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: redColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 25,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        child: Center(
          child: Text(text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) throw 'Could not launch $url';
  }
}
