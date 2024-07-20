import 'dart:io';
import 'package:app_api/app/config/const.dart';
import 'package:app_api/app/data/api.dart';
import 'package:app_api/app/data/sqlite.dart';
import 'package:app_api/app/model/cart.dart';
import 'package:app_api/app/model/product.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_page.dart';

class HomeBuilder extends StatefulWidget {
  const HomeBuilder({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeBuilder> createState() => _HomeBuilderState();
}

class _HomeBuilderState extends State<HomeBuilder> {
  final DatabaseHelper _databaseService = DatabaseHelper();

  Future<Map<String, List<ProductModel>>> _getProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<ProductModel> products = await APIRepository().getProduct(
        prefs.getString('accountID').toString(),
        prefs.getString('token').toString());

    // Group products by category
    Map<String, List<ProductModel>> categorizedProducts = {};
    for (var product in products) {
      if (!categorizedProducts.containsKey(product.categoryName)) {
        categorizedProducts[product.categoryName] = [];
      }
      categorizedProducts[product.categoryName]!.add(product);
    }
    return categorizedProducts;
  }

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

  void _navigateToCategory(BuildContext context, String categoryName, List<ProductModel> products) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(categoryName: categoryName, products: products),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<ProductModel>>>(
      future: _getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No products available"),
          );
        }
        return ListView(
          children: [
            _buildCarousel(),
            ...snapshot.data!.entries.map((entry) {
              return _buildCategory(entry.key, entry.value);
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: [
        slideimg01,
        slideimg02,
        slideimg03,
      ].map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.amber,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategory(String categoryName, List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
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
                onPressed: () => _navigateToCategory(context, categoryName, products),
                child: const Text("Xem Thêm"),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
            ),
            itemCount: products.length > 2 ? 2 : products.length,
            itemBuilder: (context, index) {
              final itemProduct = products[index];
              return _buildProduct(itemProduct, context);
            },
          ),
        ],
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
