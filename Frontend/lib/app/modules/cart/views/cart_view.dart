import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/layout/base_scaffold.dart';
import '../../../widgets/product/product_card.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseScaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      isLoading: controller.isLoading.value,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.myCart, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18.sp)),
          Text(controller.cartService.currentShop.value?.shopName ?? AppStrings.cartEmpty, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 20.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.w)),
          child: Center(child: Text('${controller.cartService.totalItems} items', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp))),
        ),
      ],
      body: controller.cartService.items.isEmpty
          ? EmptyStateWidget(
              title: AppStrings.cartEmpty,
              icon: Icons.shopping_cart_outlined,
              action: ElevatedButton(
                onPressed: () => Get.offAllNamed('/home'),
                child: const Text(AppStrings.goShopping),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: controller.cartService.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.cartService.items.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: 20.h),
                          child: _buildAddressCard(),
                        );
                      }
                      final item = controller.cartService.items[index];
                      return ProductCard(
                        product: item.product,
                        mode: ProductCardMode.cart,
                        quantity: item.quantity,
                        onAdd: () => controller.cartService.addToCart(item.product, controller.cartService.currentShop.value!),
                        onRemove: () => controller.cartService.removeFromCart(item.product),
                      );
                    },
                  ),
                ),
                _buildPaymentSection(),
              ],
            ),
    ));
  }

  Widget _buildAddressCard() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.w)),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.deliveryAddress, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                Text('House 102, Sector 17, Chandigarh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.SAVED_ADDRESSES),
            child: Text(AppStrings.change, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30.w), topRight: Radius.circular(30.w)), 
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _paymentChip('UPI', Icons.account_balance_wallet_outlined, 'UPI'),
              _paymentChip('Card', Icons.credit_card_outlined, 'CARD'),
              _paymentChip('COD', Icons.money_outlined, 'COD'),
            ],
          ),
          SizedBox(height: 25.h),
          ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.placeOrder(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 55.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    height: 22.h,
                    width: 22.h,
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text('${AppStrings.placeOrder} • ₹${controller.cartService.subtotal}', style: TextStyle(fontSize: 18.sp, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(String label, IconData icon, String paymentMethod) {
    final isSelected = controller.selectedPaymentMethod.value == paymentMethod;
    return GestureDetector(
      onTap: () => controller.selectedPaymentMethod.value = paymentMethod,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 12.h),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.grey.shade100, borderRadius: BorderRadius.circular(15.w)),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 18.sp),
            SizedBox(width: 8.w),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}
