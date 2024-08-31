import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';

import '../../../../utilities/palette.dart';

class CarouselItem extends StatefulWidget {
  const CarouselItem({Key? key, required this.carousel}) : super(key: key);
  final List carousel;
  @override
  _CarouselItemState createState() => _CarouselItemState();
}

class _CarouselItemState extends State<CarouselItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: GFCarousel(
        items: widget.carousel.map(
          (url) {
            return CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.fill,
              width: MediaQuery.of(context).size.width,
              placeholder: (context, url) => const CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          },
        ).toList(),
        viewportFraction: 1.0,
        autoPlay: true,
        hasPagination: true,
        height: MediaQuery.of(context).size.width < 600 ? 220.0 : 500.0,
        pauseAutoPlayOnTouch: const Duration(seconds: 3),
        scrollPhysics: widget.carousel.length > 1
            ? const ScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        activeIndicator: Colors.red,
        passiveIndicator: Colors.white,
        onPageChanged: (index) {
          setState(() {
            index;
          });
        },
      ),
    );
  }
}
