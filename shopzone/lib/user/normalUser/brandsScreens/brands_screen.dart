import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/widgets/seller_text_delegate_header_widget.dart';
import 'package:shopzone/user/models/brands.dart';
import 'package:shopzone/user/models/sellers.dart';
import 'brands_ui_design_widget.dart';

class BrandsScreen extends StatefulWidget {
  final Sellers? model;

  BrandsScreen({this.model});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  Stream<List<Brands>> _getBrands(String uid) async* {
    print('---------------  ${widget.model}');

    final response =
        await http.get(Uri.parse('${API.sellerBrandView}?uid=$uid'));
    print("response.body");
    print('${API.sellerBrandView}?uid=$uid');
    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> data = json.decode(response.body);

      yield data.map((brandData) => Brands.fromJson(brandData)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 20,
        title: const Text(
          "Shop Zone",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextDelegateHeaderWidget(
              title: '${widget.model!.sellerName} - Brands',
            ),
          ),
          StreamBuilder(
            stream: _getBrands(widget.model!.sellerId.toString()),
            builder: (context, AsyncSnapshot<List<Brands>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: _buildShimmerEffect(),
                );
              } else if (dataSnapshot.hasData && dataSnapshot.data!.isNotEmpty) {
                return SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 1,
                  staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                  itemBuilder: (context, index) {
                    Brands brandsModel = dataSnapshot.data![index];

                    return BrandsUiDesignWidget(
                      model: brandsModel,
                    );
                  },
                  itemCount: dataSnapshot.data!.length,
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      "No brands exist",
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
