import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/product_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: kSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // watch() rebuilds this screen whenever the cart changes.
    final p = context.watch<ProductProvider>();
    final lines = p.cart.values.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBg,
        title: const Text('My bag', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (lines.isNotEmpty)
            TextButton(onPressed: p.clearCart, child: const Text('Clear')),
        ],
      ),
      body: lines.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('Your bag is empty',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Add something you like', style: TextStyle(color: Colors.black45)),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final l = lines[i];
                    final id = l.product.id;
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: kSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: l.product.thumbnail,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${l.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: kAccent, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _qtyBtn(Icons.remove, () => p.changeQty(id, -1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('${l.qty}',
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                    _qtyBtn(Icons.add, () => p.changeQty(id, 1)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () => p.removeFromCart(id),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: lines.isEmpty
          ? null
          : Container(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Total', style: TextStyle(color: Colors.black45)),
                          Text(
                            '\$${p.cartTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: kAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final messenger = ScaffoldMessenger.of(context);
                          p.clearCart();
                          Navigator.of(context).pop();
                          messenger.showSnackBar(const SnackBar(
                            content: Text('Order placed (demo)'),
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                        child: const Text('Checkout',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
