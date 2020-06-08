class Product {
  final String name;
  final double confidence;

  String get percentage => (confidence * 100).toStringAsFixed(1);

  Product({this.name, this.confidence});
}
