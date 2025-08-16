import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();
  
  // Flag to disable ads for iOS App Store review
  static const bool _adsEnabled = true; // Set to true to enable ads

  // Production AdMob IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2077503952644064/2671736033';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2077503952644064/9516345987';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2077503952644064/1358654365'; // Android interstitial ad ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2077503952644064/2948952106';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      // Production Android rewarded ad unit ID
      return 'ca-app-pub-2077503952644064/3941746794';
    } else if (Platform.isIOS) {
      // Production iOS rewarded ad unit ID
      return 'ca-app-pub-2077503952644064/2824090339';
    }
    throw UnsupportedError('Unsupported platform');
  }

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;
  final int _maxAttempts = 3;

  void loadInterstitialAd() {
    if (!_adsEnabled) return;
    
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          if (_interstitialLoadAttempts < _maxAttempts) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd({Function? onAdClosed}) {
    if (!_adsEnabled) {
      onAdClosed?.call();
      return;
    }
    
    if (_interstitialAd == null) {
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
        onAdClosed?.call();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void loadRewardedAd() {
    if (!_adsEnabled) return;
    
    print('Loading rewarded ad with ID: $rewardedAdUnitId');
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('Rewarded ad loaded successfully');
          _rewardedAd = ad;
          _rewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          print('Failed to load rewarded ad: ${error.message}');
          _rewardedLoadAttempts++;
          _rewardedAd = null;
          if (_rewardedLoadAttempts < _maxAttempts) {
            print('Retrying to load rewarded ad (attempt ${_rewardedLoadAttempts + 1}/$_maxAttempts)');
            Future.delayed(const Duration(seconds: 2), () {
              loadRewardedAd();
            });
          }
        },
      ),
    );
  }

  void showRewardedAd({
    required Function onRewarded,
    Function? onAdClosed,
  }) {
    if (!_adsEnabled) {
      // Simulate reward without showing ad when ads are disabled
      onRewarded();
      onAdClosed?.call();
      return;
    }
    
    if (_rewardedAd == null) {
      onAdClosed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedAd();
        onAdClosed?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
    _rewardedAd = null;
  }

  bool get isInterstitialAdReady => (!_adsEnabled || Platform.isIOS) ? false : _interstitialAd != null;
  bool get isRewardedAdReady => !_adsEnabled ? true : _rewardedAd != null; // Always true when ads are disabled

  BannerAd createBannerAd() {
    // Return null when ads are disabled
    if (!_adsEnabled) {
      throw UnsupportedError('Ads are disabled');
    }
    
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }
}