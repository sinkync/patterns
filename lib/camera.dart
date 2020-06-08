import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patterns/models/product.dart';
import 'package:patterns/photo_detail.dart';
import 'package:provider/provider.dart';
import 'package:tflite/tflite.dart';

class ScreenCamera extends StatefulWidget {
  @override
  _ScreenCameraState createState() => _ScreenCameraState();
}

class _ScreenCameraState extends State<ScreenCamera> {
  File _image;
  final picker = ImagePicker();

  List<Product> products = [];
  bool isLoading = false;
  bool isFirstOpening = true;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
      _runModelOnImage(path: _image.path);
    });
  }

  @override
  void initState() {
    _loadModels();
    super.initState();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patterns'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : _getBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: getImage,
        child: Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  // Widgets

  Widget _getBody() {
    return Center(
        child: isFirstOpening
            ? _getIntroduction()
            : products.isEmpty ? _getNotFound() : _getProductInfo());
  }

  Widget _getProductInfo() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: ListView.builder(
            itemCount: products.length == 1
                ? products.length + 2
                : products.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _getProductListTile(product: products[index]);
              }
              if (index == 1) {
                return Container(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('Benzerleri',
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold)));
              }

              return products.length == 1
                  ? _getNotFoundForSimilarProducts()
                  : _getProductListTile(product: products[index - 1]);
            }));
  }

  Widget _getProductListTile({Product product}) {
    return ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
        leading: ClipRRect(
            child: GestureDetector(
              child: Hero(
                  tag: 'imageHero-' + product.name,
                  child: _getProductImageWithName(name: product.name)),
              onTap: () {
                Navigator.push(context,
                    FadeRoute(page: ScreenImageDetail(product: product)));
              },
            ),
            borderRadius: BorderRadius.circular(8.0)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            product.name,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.0),
          Text(
            'Doğruluk Oranı: %' + product.percentage,
            style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 14.0,
                fontWeight: FontWeight.w500),
          )
        ]));
  }

  Widget _getIntroduction() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Center(
        child: Text(
          'Bilgi edinmek istediğiniz ürünü kamera ile taratabilirsiniz',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey, fontSize: 15.0, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _getNotFound() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Text(
        'Yüklediğiniz desenle ilişkili ürün bulunamadı',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.grey, fontSize: 15.0, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _getNotFoundForSimilarProducts() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Center(
        child: Text(
          'Benzer ürün bulunamadı. Taratılan ürünün doğruluk oranı yüksek olduğu durumlarda benzer ürünler listelenmeyebilir',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey, fontSize: 15.0, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  // Tensorflow

  _loadModels() async {
    await Tflite.loadModel(
        model: "assets/models/model.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 2);
  }

  void _runModelOnImage({String path}) async {
    isLoading = true;
    isFirstOpening = false;

    var output = await Tflite.runModelOnImage(
      path: path,
    );

    setState(() {
      products = output
          .map((product) => Product(
              name: product['label'].toString(),
              confidence: product['confidence'].toDouble()))
          .toList();

      debugPrint('Products ' + output.toString());
      isLoading = false;
    });
  }

  // Helper

  Image _getProductImageWithName({String name}) {
    if (name == '0 Product 1') {
      return Image.asset('assets/products/product-1.jpg',
          width: 90.0, height: 90.0, fit: BoxFit.fill);
    } else if (name == '1 Product 2') {
      return Image.asset('assets/products/product-2.jpg',
          width: 90.0, height: 90.0, fit: BoxFit.fill);
    } else if (name == '2 Product 3') {
      return Image.asset('assets/products/product-3.jpg',
          width: 90.0, height: 90.0, fit: BoxFit.fill);
    } else {
      return Image.asset('assets/products/product-4.jpg',
          width: 90.0, height: 90.0, fit: BoxFit.fill);
    }
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
