# Hai Nong - v2

Đạm Cà Mau, Chợ 2 Nông, 2Nông: Diễn đàn nông nghiệp (Flutter 2.x)

# Change xcode 10.x -> 14.x or later
#
# Step1: for build
# sudo gem install xcodeproj
# pod update
# pod install
#
# Step 2: for Archive
# Edit file: hainong-v2/ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh
# Line 44: source="$(readlink "${source}")" => source="$(readlink -f "${source}")"

#flutter_launcher_icons: 0.12.0
#flutter pub run flutter_launcher_icons:main

#flutter_icons:
#  ios: true
#  android: false
#  image_path: "build_info/ic_app.png"

#Fade in image
#@override
#Widget build(BuildContext context) {
#change =>    if (widget.wasSynchronouslyLoaded || (_placeholderOpacityAnimation != null && _placeholderOpacityAnimation!.isCompleted)) {
#        return widget.target;
#    }

#change =>   return _placeholderOpacityAnimation != null ? Stack(
#      fit: StackFit.passthrough,
#      alignment: AlignmentDirectional.center,
#      // Text direction is irrelevant here since we're using center alignment,
#      // but it allows the Stack to avoid a call to Directionality.of()
#      textDirection: TextDirection.ltr,
#      children: <Widget>[
#        widget.target,
#        widget.placeholder,
#      ],
#change =>    ) : widget.target;
#}