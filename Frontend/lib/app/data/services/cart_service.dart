import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';

class CartService extends GetxService {
  final Rxn<ShopModel> currentShop = Rxn<ShopModel>();
  final RxList<CartItem> items = <CartItem>[].obs;

  double get subtotal => items.fold(0, (sum, item) => sum + (item.product.price! * item.quantity));
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(ProductModel product, ShopModel shop) {
    if (currentShop.value != null && currentShop.value!.id != shop.id) {
      items.clear();
    }
    
    currentShop.value = shop;
    
    int index = items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      items[index].quantity++;
      items.refresh();
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
  }

  void removeFromCart(ProductModel product) {
    int index = items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
        items.refresh();
      } else {
        items.removeAt(index);
      }
    }
    
    if (items.isEmpty) {
      currentShop.value = null;
    }
  }

  void clearCart() {
    items.clear();
    currentShop.value = null;
  }
}

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
