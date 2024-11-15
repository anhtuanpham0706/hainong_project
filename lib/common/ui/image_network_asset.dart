import '../ui/import_lib_base_ui.dart';
import '../util/util.dart';
class ImageNetworkAsset extends StatelessWidget {
  final String path, asset, error;
  final BoxFit fit;
  final bool cache;
  final int rateCache;
  final double scale;
  final double? width, height, opacity;
  final Widget? uiError;
  const ImageNetworkAsset({this.path = '', this.fit = BoxFit.cover, this.scale = 1.0, this.cache = false, this.rateCache = 1,
    this.width, this.height, this.asset = 'assets/images/ic_default.png',
    this.error = 'assets/images/ic_default.png', this.opacity, this.uiError, Key? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return uiError??Image.asset(asset, fit: fit, scale: scale, width: width, height: height, opacity: AlwaysStoppedAnimation(opacity??1.0));
    final temp = FadeInImage.assetNetwork(placeholder:asset, image: Util.getRealPath(path),
        fadeInDuration: const Duration(milliseconds: 50),
        fadeOutDuration: const Duration(milliseconds: 50),
        imageScale: scale, fit: fit, width: width, height: height, placeholderFit: BoxFit.fill,
        imageCacheWidth: cache && width != null ? (rateCache * width!).toInt() : null,
        imageErrorBuilder: (_,__,___) => uiError??Image.asset(error, fit: BoxFit.fill, width: width, height: height),
        placeholderErrorBuilder: (_,__,___) => uiError??Image.asset(error, fit: BoxFit.fill, width: width, height: height)
    );
    return opacity != null ? Opacity(opacity: opacity!, child: temp) : temp;
  }
}