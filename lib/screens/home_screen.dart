import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_card.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  // Columns are decided by max card width, so phones get 2 columns
  // and tablets / wide windows automatically get more.
  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 240,
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: 0.66,
  );

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // Wait for the first frame so context.read is safe, then load page 1.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().init();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Infinite scroll trigger: when we're within 300px of the bottom,
  // ask the provider for the next page. The provider ignores the call
  // if a request is already running or there's nothing left.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<ProductProvider>().loadMore();
    }
  }

  // If the first pages don't fill the screen (wide windows, tablets),
  // there's nothing to scroll, so the scroll listener never fires.
  // This keeps loading until the screen is full or data runs out.
  void _fillScreenIfNeeded() {
    if (!mounted || !_scroll.hasClients) return;
    final p = context.read<ProductProvider>();
    if (_scroll.position.maxScrollExtent <= 300 &&
        p.hasMore &&
        !p.isLoading &&
        !p.hasError &&
        p.products.isNotEmpty) {
      p.loadMore();
    }
  }

  // Waits until the user stops typing for 400ms before searching,
  // so we don't fire a request on every keystroke.
  void _onSearchChanged(String v) {
    setState(() {}); // updates the clear (x) button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<ProductProvider>().setQuery(v.trim());
    });
  }

  String _pretty(String slug) => slug
      .split('-')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, p, _) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _fillScreenIfNeeded());
            final showSkeleton = p.products.isEmpty && (p.isLoading || !p.loadedOnce);
            final showEmpty =
                p.products.isEmpty && p.loadedOnce && !p.isLoading && !p.hasError;

            return RefreshIndicator(
              color: kAccent,
              onRefresh: p.refresh,
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _header(p)),
                  SliverToBoxAdapter(child: _chips(p)),
                  if (showSkeleton)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      sliver: SliverGrid(
                        gridDelegate: _gridDelegate,
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => const SkeletonCard(),
                          childCount: 6,
                        ),
                      ),
                    )
                  else if (showEmpty)
                    SliverToBoxAdapter(child: _empty(p))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      sliver: SliverGrid(
                        gridDelegate: _gridDelegate,
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => ProductCard(
                            key: ValueKey(p.products[i].id),
                            product: p.products[i],
                          ),
                          childCount: p.products.length,
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(child: _footer(p)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(ProductProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello there 👋',
                        style: TextStyle(fontSize: 13, color: Colors.black45)),
                    SizedBox(height: 2),
                    Text('Find your next favourite',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Badge(
                label: Text('${p.cartCount}'),
                isLabelVisible: p.cartCount > 0,
                backgroundColor: kAccent,
                child: IconButton(
                  tooltip: 'My bag',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 26),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Log out',
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                              p.setQuery('');
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: kInk,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: PopupMenuButton<String>(
                  tooltip: 'Sort',
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  onSelected: (v) {
                    switch (v) {
                      case 'low':
                        p.setSort('price', 'asc');
                        break;
                      case 'high':
                        p.setSort('price', 'desc');
                        break;
                      case 'rating':
                        p.setSort('rating', 'desc');
                        break;
                      default:
                        p.setSort(null, 'asc');
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'none', child: Text('Featured')),
                    PopupMenuItem(value: 'low', child: Text('Price: low to high')),
                    PopupMenuItem(value: 'high', child: Text('Price: high to low')),
                    PopupMenuItem(value: 'rating', child: Text('Top rated')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chips(ProductProvider p) {
    final items = ['All', ...p.categories];
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final slug = i == 0 ? null : items[i];
          final selected = p.category == slug && (i != 0 || p.query.isEmpty);
          return ChoiceChip(
            label: Text(i == 0 ? 'All' : _pretty(items[i])),
            selected: selected,
            showCheckmark: false,
            selectedColor: kAccent,
            backgroundColor: Colors.white,
            side: BorderSide.none,
            labelStyle: TextStyle(
              color: selected ? Colors.white : kInk,
              fontWeight: FontWeight.w500,
            ),
            onSelected: (_) {
              _searchCtrl.clear();
              setState(() {});
              p.setCategory(slug);
            },
          );
        },
      ),
    );
  }

  Widget _empty(ProductProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          const Text('No products found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Try a different search or category',
              style: TextStyle(color: Colors.black45)),
          TextButton(
            onPressed: () {
              _searchCtrl.clear();
              setState(() {});
              p.setCategory(null);
            },
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  // Bottom of the list: spinner while loading more, retry on error,
  // and a small message once everything has been loaded.
  Widget _footer(ProductProvider p) {
    Widget child = const SizedBox(height: 24);
    if (p.isLoading && p.products.isNotEmpty) {
      child = const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 3, color: kAccent),
          ),
        ),
      );
    } else if (p.hasError) {
      child = Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Couldn't load products. Check your connection."),
            TextButton(onPressed: p.loadMore, child: const Text('Try again')),
          ],
        ),
      );
    } else if (!p.hasMore && p.products.isNotEmpty) {
      child = const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text("You've reached the end",
              style: TextStyle(color: Colors.black38)),
        ),
      );
    }
    return child;
  }
}
