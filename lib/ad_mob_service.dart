import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  
  // 배너광고 unit id 가져오기 (개발시 테스트 id 임, 배포 시 변경 필요)
  static String? get bannerAdUnitID {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'test';
    }
    return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded!!'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad fail to load : ${error}');
    },
    onAdOpened: (ad) => debugPrint('Ad opened'),
    onAdClosed: (ad) => debugPrint('Ad closed'),
  );
}