import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final _service = ProductService();
  static const _pageSize = 20;

  final List<Product> products = [];
  List<String> categories = [];
  final Set<int> _favs = {};
  // Cart: product id -> line (product + quantity).
  final Map<int, CartLine> cart = {};

  int get cartCount => cart.values.fold(0, (sum, l) => sum + l.qty);
  double get cartTotal =>
      cart.values.fold(0.0, (sum, l) => sum + l.product.price * l.qty);

  bool isLoading = false;
  bool hasMore = true;
  bool hasError = false;
  bool loadedOnce = false;

  String query = '';
  String? category;
  String? sortBy;
  String order = 'asc';

  // Bumped on every refresh. If a slow response from an old search comes
  // back after a new search started, we spot the mismatch and ignore it.
  int _generation = 0;

  bool isFav(int id) => _favs.contains(id);

  void toggleFav(int id) {
    _favs.contains(id) ? _favs.remove(id) : _favs.add(id);
    notifyListeners();
  }

  void addToCart(Product p) {
    final line = cart[p.id];
    if (line == null) {
      cart[p.id] = CartLine(p, 1);
    } else {
      line.qty++;
    }
    notifyListeners();
  }

  // delta is +1 or -1; a quantity of 0 removes the item.
  void changeQty(int id, int delta) {
    final line = cart[id];
    if (line == null) return;
    line.qty += delta;
    if (line.qty <= 0) cart.remove(id);
    notifyListeners();
  }

  void removeFromCart(int id) {
    cart.remove(id);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  Future<void> init() async {
    try {
      categories = await _service.categories();
    } catch (_) {
      // Categories are optional; the app still works without them.
    }
    await refresh();
  }

  /// Start over from page 1. Used by pull-to-refresh and whenever
  /// search, category or sort changes.
  Future<void> refresh() async {
    _generation++;
    products.clear();
    hasMore = true;
    hasError = false;
    isLoading = false;
    await loadMore();
  }

  /// Fetches the next page. Called by the scroll listener near the bottom.
  Future<void> loadMore() async {
    if (isLoading || !hasMore) return; // guards against duplicate requests
    final gen = _generation;
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final page = await _service.fetch(
        skip: products.length,
        limit: _pageSize,
        query: query,
        category: category,
        sortBy: sortBy,
        order: order,
      );
      if (gen != _generation) return; // stale response, drop it
      products.addAll(page);
      hasMore = page.length == _pageSize; // a short page means we hit the end
    } catch (_) {
      if (gen != _generation) return;
      hasError = true;
    }
    isLoading = false;
    loadedOnce = true;
    notifyListeners();
  }

  void setQuery(String q) {
    query = q;
    category = null;
    refresh();
  }

  void setCategory(String? c) {
    category = c;
    query = '';
    refresh();
  }

  void setSort(String? by, String ord) {
    sortBy = by;
    order = ord;
    refresh();
  }
}

class CartLine {
  final Product product;
  int qty;
  CartLine(this.product, this.qty);
}
