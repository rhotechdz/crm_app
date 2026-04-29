import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talabati/features/catalog/data/models/product.dart';
import 'package:talabati/features/catalog/data/repositories/catalog_repository.dart';

final catalogRepositoryProvider = Provider((ref) => CatalogRepository());

final productsProvider = NotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);

class SearchProductQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  @override
  set state(String value) => super.state = value;
}

final searchProductQueryProvider = NotifierProvider<SearchProductQueryNotifier, String>(SearchProductQueryNotifier.new);

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider);
  final query = ref.watch(searchProductQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return products;
  }

  return products.where((product) {
    return product.name.toLowerCase().contains(query);
  }).toList();
});

class ProductsNotifier extends Notifier<List<Product>> {
  CatalogRepository get _repository => ref.read(catalogRepositoryProvider);

  @override
  List<Product> build() {
    loadProducts();
    return [];
  }

  Future<void> loadProducts() async {
    final products = await _repository.getProducts();
    state = products;
  }

  Future<void> addProduct(Product product) async {
    await _repository.addProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product, List<String> variantsToDelete) async {
    await _repository.updateProduct(product, variantsToDelete);
    await loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    await loadProducts();
  }

  Future<bool> isProductInOrders(String id) async {
    return await _repository.isProductInOrders(id);
  }
}
