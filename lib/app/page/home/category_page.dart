import 'package:app_api/app/data/sqlite.dart';
import 'package:app_api/app/model/cart.dart';
import 'package:app_api/app/model/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  final List<ProductModel> products;

  const CategoryPage({
    Key? key,
    required this.categoryName,
    required this.products,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final DatabaseHelper _databaseService = DatabaseHelper();

  Future<void> _onSave(ProductModel pro) async {
    _databaseService.insertProduct(Cart(
        productID: pro.id,
        name: pro.name,
        des: pro.description,
        price: pro.price,
        img: pro.imageUrl,
        count: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
        ),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final itemProduct = widget.products[index];
          return _buildProduct(itemProduct, context);
        },
      ),
    );
  }

  Widget _buildProduct(ProductModel pro, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (pro.imageUrl == null || pro.imageUrl == '' || pro.imageUrl == 'Null')
                  ? const SizedBox()
                  : Container(
                      height: 150, // Increased height for the image
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(pro.imageUrl), fit: BoxFit.cover)),
                      alignment: Alignment.center,
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              pro.name,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              NumberFormat('#,##0').format(pro.price),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(pro.description),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  _onSave(pro);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, // Background color
                ),
                child: const Text("Mua Ngay"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
