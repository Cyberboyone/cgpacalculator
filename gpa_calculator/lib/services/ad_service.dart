import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps AdMob setup. Uses Google's official TEST ad unit IDs so the app
/// runs safely out of the box. Replace [bannerAdUnitId] with your real
/// AdMob unit ID before publishing (see README).
class AdService {
  static Future<void> init() => MobileAds.instance.initialize();

  static String get bannerAdUnitId {
    // Google's public test IDs (safe to ship during development).
    // https://developers.google.com/admob/android/test-ads
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS test banner
  }

  static BannerAd createBanner({required void Function() onLoaded}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }
}
