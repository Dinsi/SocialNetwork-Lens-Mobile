import 'package:flutter/material.dart';
// import 'package:transparent_image/transparent_image.dart';

class ImageContainer extends StatelessWidget {
  final String imageUrl;
  final int imageHeight;
  final int imageWidth;
  final GestureTapCallback onTap;
  final GestureTapCallback onDoubleTap;
  final double paddingDiff;

  const ImageContainer(
      {@required this.imageUrl,
      @required this.imageHeight,
      @required this.imageWidth,
      @required this.onTap,
      @required this.onDoubleTap,
      this.paddingDiff = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _calculatePlaceholderHeight(context),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.white24,
          onTap: this.onTap, //this.onTap,
          onDoubleTap: this.onDoubleTap,
        ),
      ),
    );
  }

  double _calculatePlaceholderHeight(BuildContext context) {
    if (MediaQuery.of(context).size.width - paddingDiff >= imageWidth) {
      return imageHeight.toDouble();
    }

    return ((MediaQuery.of(context).size.width - paddingDiff) *
        imageHeight /
        imageWidth);
  }
}
