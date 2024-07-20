import 'package:app_api/app/data/api.dart';
import 'package:app_api/app/model/product.dart';
import 'package:app_api/app/page/product/category_product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_product.dart';
import 'product_add.dart';

class ProductBuilder extends StatefulWidget {
  const ProductBuilder({Key? key}) : super(key: key);

  @override
  State<ProductBuilder> createState() => _ProductBuilderState();
}

class _ProductBuilderState extends State<ProductBuilder> {
  Future<List<ProductModel>> _getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await APIRepository().getProduct(prefs.getString('accountID').toString(), prefs.getString('token').toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No products available"));
        }
        
        final products = snapshot.data!;
        final categories = _getCategories(products);

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: categories.keys.map((categoryName) {
            final categoryProducts = categories[categoryName]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToCategory(context, categoryName, categoryProducts),
                      child: const Text("Xem Thêm"),
                    ),
                  ],
                ),
                Column(
                  children: categoryProducts.take(2).map((product) => _buildProduct(product, context)).toList(),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Map<String, List<ProductModel>> _getCategories(List<ProductModel> products) {
    final Map<String, List<ProductModel>> categories = {};
    for (var product in products) {
      categories.putIfAbsent(product.categoryName, () => []).add(product);
    }
    return categories;
  }

  void _navigateToCategory(BuildContext context, String categoryName, List<ProductModel> products) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryProducts(
          categoryName: categoryName,
          products: products,
        ),
      ),
    );
  }

  Widget _buildProduct(ProductModel product, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: (product.imageUrl == null || product.imageUrl == '' || product.imageUrl == 'Null')
                  ? const SizedBox()
                  : Container(
                      height: 150, // Increased height for the image
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(product.imageUrl), fit: BoxFit.cover)),
                      alignment: Alignment.center,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    NumberFormat('#,##0').format(product.price),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text('Description: ' + product.description),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                setState(() async {
                  await APIRepository().removeProduct(product.id, pref.getString('accountID').toString(), pref.getString('token').toString());
                });
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => ProductAdd(
                            isUpdate: true,
                            productModel: product,
                          ),
                          fullscreenDialog: true,
                        ),
                      )
                      .then((_) => setState(() {}));
                });
              },
              icon: Icon(
                Icons.edit,
                color: Colors.yellow.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
