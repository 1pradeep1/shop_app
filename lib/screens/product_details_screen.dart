import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final fav = context.select<ProductProvider, bool>((p) => p.isFav(product.id));

    return Scaffold(
      backgroundColor: kSoft,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.read<ProductProvider>().toggleFav(product.id),
            icon: Icon(
              fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: fav ? kAccent : kInk,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          // On tablets / web the content stays a readable width.
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              SizedBox(
                height: 280,
                child: Hero(
                  // Same tag as the card image = smooth shared transition.
                  tag: 'product-${product.id}',
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.replaceAll('-', ' ').toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11, letterSpacing: 1.2, color: Colors.black45),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(product.rating.toStringAsFixed(1)),
                            if (product.brand != null) ...[
                              const SizedBox(width: 14),
                              Text(product.brand!,
                                  style: const TextStyle(color: Colors.black54)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w800, color: kAccent),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.description,
                          style: const TextStyle(height: 1.5, color: Colors.black87),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      context.read<ProductProvider>().addToCart(product);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: const Text('Added to your bag'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'VIEW',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const CartScreen()),
                            ),
                          ),
                        ));
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Add to bag',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
