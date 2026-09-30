import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // select() rebuilds this card only when ITS favourite state changes,
    // not every time anything in the provider changes.
    final fav = context.select<ProductProvider, bool>((p) => p.isFav(product.id));

    // Small fade + slide-up when the card first appears.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Hero(
                          tag: 'product-${product.id}',
                          child: CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox.shrink(),
                            errorWidget: (_, __, ___) => const Center(
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: Colors.black26),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: GestureDetector(
                        onTap: () => context.read<ProductProvider>().toggleFav(product.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          // The icon swaps with a small pop animation.
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                            child: Icon(
                              fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              key: ValueKey(fav),
                              size: 18,
                              color: fav ? kAccent : Colors.black45,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.brand ?? product.category.replaceAll('-', ' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14, color: kAccent),
                        ),
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
