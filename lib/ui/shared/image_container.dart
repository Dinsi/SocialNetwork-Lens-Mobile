import 'package:flutter/material.dart';
// import 'package:transparent_image/transparent_image.dart';

class ImageContainer extends StatelessWidget {
  final String imageUrl;
  final int imageHeight;
  final int imageWidth;
  final GestureTapCallback onTap;
  final GestureTapCallback onDoubleTap;

  const ImageContainer(
      {@required this.imageUrl,
      @required this.imageHeight,
      @required this.imageWidth,
      @required this.onTap,
      @required this.onDoubleTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _calculatePlaceholderHeight(context),
      color: Colors.grey[300],
      child: Stack(
        children: <Widget>[
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.fitWidth,
            ),
            /*FadeInImage.memoryNetwork(
              fit: BoxFit.fitWidth,
              placeholder: kTransparentImage,
              image: imageUrl,
            ),*/
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.white24,
              onTap: this.onTap,
              onDoubleTap: this.onDoubleTap,
            ),
          ),
        ],
      ),
    );
  }

  double _calculatePlaceholderHeight(BuildContext context) {
    if (MediaQuery.of(context).size.width >= imageWidth) {
      return imageHeight.toDouble();
    }

    return MediaQuery.of(context).size.width * imageHeight / imageWidth;
  }
}
