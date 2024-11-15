import 'dart:io';
import 'package:flutter/material.dart';
import 'avatar_circle_widget.dart';

class ButtonImageCircleWidget extends StatelessWidget {
  final double size;
  final Function? onTap;
  final String link;
  final Widget? child;
  final String assetsImageReplace;
  final File? imageFile;

  const ButtonImageCircleWidget(this.size, this.onTap, {this.imageFile, this.link = '', this.child,
      this.assetsImageReplace = 'assets/images/v2/ic_avatar_drawer_v2.png', Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    Widget image = imageFile != null ? _CreateImageFile(size, imageFile!) :
        child ?? AvatarCircleWidget(link: link, size: size, assetsImageReplace: assetsImageReplace);
    return Material(color: Colors.transparent,
        child: InkWell(borderRadius: BorderRadius.circular(size),
            onTap: () {onTap!();}, child: image));
  }
}

class _CreateImageFile extends StatelessWidget {
  final File imageFile;
  final double size;
  const _CreateImageFile(this.size, this.imageFile);
  @override
  Widget build(context) => Container(width: size, height: size,
      decoration: BoxDecoration(color: Colors.black54,
          boxShadow: [BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1, blurRadius: 7,
              offset: const Offset(0, 1))],
          borderRadius: BorderRadius.circular(size),
          image: DecorationImage(fit: BoxFit.cover, image: Image.file(imageFile).image)));
}
