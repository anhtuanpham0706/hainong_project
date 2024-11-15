import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'import_lib_base_ui.dart';

class GoogleAds extends StatefulWidget {
  const GoogleAds({Key? key}) : super(key: key);
  @override
  _GoogleAdsState createState() => _GoogleAdsState();
}

class _GoogleAdsState extends State<GoogleAds> {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false, _isClose = false;
  late Orientation _currentOrientation;

  @override
  void dispose() {
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    _loadAd();
  }

  @override
  Widget build(BuildContext context) => OrientationBuilder(
    builder: (context, orientation) {
      if (_isClose) return const SizedBox();

      if (_currentOrientation == orientation && _anchoredAdaptiveAd != null && _isLoaded) {
        return Stack(children: [
          SizedBox(width: 1.sw, height: _anchoredAdaptiveAd!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredAdaptiveAd!)),
          SizedBox(height: _anchoredAdaptiveAd!.size.height.toDouble() + 23.sp + 5, child: GestureDetector(onTap: _close,
              child: Container(width: 46.sp + 10, height: 46.sp + 10, padding: const EdgeInsets.all(5),
                margin: EdgeInsets.only(right: 5, bottom: _anchoredAdaptiveAd!.size.height.toDouble() - 23.sp - 5),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(50)),
                child: Icon(Icons.close, color: Colors.white, size: 46.sp))))
        ], alignment: Alignment.bottomRight);
      }
      if (_currentOrientation != orientation) {
        _currentOrientation = orientation;
        _loadAd();
      }
      return const SizedBox();
    },
  );

  Future<void> _loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isLoaded = false;
    });

    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String env = prefs.getString('env')??'';
    if (env.isEmpty) {
      env = Platform.isAndroid
          ? 'ca-app-pub-9002780038101525/8833031699'
          : 'ca-app-pub-9002780038101525/3312261648';
    } else {
      env = Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: env,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  void _close() => setState(() => _isClose = true);
}
