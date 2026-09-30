import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';

/// All network calls live here so the UI never touches http directly.
class ProductService {
  static const _base = 'https://dummyjson.com/products';

  /// Loads one page. [skip] is how many items we already have,
  /// which is exactly the offset the API needs for the next page.
  Future<List<Product>> fetch({
    required int skip,
    int limit = 20,
    String query = '',
    String? category,
    String? sortBy,
    String order = 'asc',
  }) async {
    String url;
    if (query.isNotEmpty) {
      url = '$_base/search?q=${Uri.encodeQueryComponent(query)}&limit=$limit&skip=$skip';
    } else if (category != null) {
      url = '$_base/category/$category?limit=$limit&skip=$skip';
    } else {
      url = '$_base?limit=$limit&skip=$skip';
    }
    if (sortBy != null) url += '&sortBy=$sortBy&order=$order';

    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Server returned ${res.statusCode}');
    }
    final list = jsonDecode(res.body)['products'] as List;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> categories() async {
    final res = await http.get(Uri.parse('$_base/category-list'));
    if (res.statusCode != 200) return [];
    return List<String>.from(jsonDecode(res.body));
  }
}
