import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_api/app/model/product.dart';
import 'package:app_api/app/data/api.dart';
import 'product_add.dart';

class CategoryProducts extends StatelessWidget {
  final String categoryName;
  final List<ProductModel> products;

  const CategoryProducts({
    Key? key,
    required this.categoryName,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProduct(product, context);
        },
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
                    '${product.price}',
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
                await APIRepository().removeProduct(product.id, pref.getString('accountID').toString(), pref.getString('token').toString());
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
            IconButton(
              onPressed: () {
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
                    .then((_) {
                      // Optional: Add any additional code to refresh the list if needed
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
