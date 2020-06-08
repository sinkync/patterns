import 'package:flutter/material.dart';
import 'package:patterns/models/product.dart';

class ScreenImageDetail extends StatelessWidget {
  final Product product;

  const ScreenImageDetail({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
              tag: 'imageHero-' + product.name,
              child: _getProductImageWithName(name: product.name)),
        ),
        onTap: () {
          Navigator.pop(context);
        },
        onVerticalDragStart: (f) {
          Navigator.pop(context);
        },
      ),
    );
  }

  // Helper

  Image _getProductImageWithName({String name}) {
    if (name == '0 Product 1') {
      return Image.asset('assets/products/product-1.jpg', fit: BoxFit.fill);
    } else if (name == '1 Product 2') {
      return Image.asset('assets/products/product-2.jpg', fit: BoxFit.fill);
    } else if (name == '2 Product 3') {
      return Image.asset('assets/products/product-3.jpg', fit: BoxFit.fill);
    } else {
      return Image.asset('assets/products/product-4.jpg', fit: BoxFit.fill);
    }
  }
}

