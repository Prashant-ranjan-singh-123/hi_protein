import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import '../../../../utilities/palette.dart';

class CarouselDisplay extends StatefulWidget{
  const CarouselDisplay({Key? key, required this.image}):super(key:key);
  final List image;
  @override
  _CarouselDisplayState createState() => _CarouselDisplayState();
}
class _CarouselDisplayState extends State<CarouselDisplay>{
  @override
  Widget build(BuildContext context){
    return GFCarousel(
      items: widget.image.map(
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
      height: MediaQuery.of(context).size.width<600?220.0:500.0,
      pauseAutoPlayOnTouch: const Duration(seconds: 3),
      scrollPhysics: widget.image.length>1?const ScrollPhysics():const NeverScrollableScrollPhysics(),
      activeIndicator: Colors.black,
      passiveIndicator: Palette.background,
      onPageChanged:(index){setState((){index;});
      },
    );
  }
}
