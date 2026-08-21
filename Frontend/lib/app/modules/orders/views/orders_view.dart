import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';
import '../../../widgets/layout/base_scaffold.dart';
import '../../../widgets/order/order_list_item.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/layout/custom_bottom_nav.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseScaffold(
      title: AppStrings.ordersLabel,
      isLoading: controller.isLoading.value,
      body: RefreshIndicator(
        onRefresh: () => controller.refreshOrders(),
        child: controller.orders.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: EmptyStateWidget(
                    title: 'No orders yet',
                    icon: Icons.receipt_long_outlined,
                    action: ElevatedButton(
                      onPressed: () => Get.offAllNamed(Routes.HOME),
                      child: const Text(AppStrings.goShopping),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  return OrderListItem(
                    order: order,
                    onTap: () => Get.toNamed(
                      Routes.ORDER_TRACKING,
                      arguments: OrderArguments.fromData(order),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Get.offAllNamed(Routes.HOME);
          if (index == 1) Get.offAllNamed(Routes.DISCOVER);
          if (index == 2) Get.toNamed(Routes.CHAT);
          if (index == 4) Get.offAllNamed(Routes.PROFILE);
        },
      ),
    ));
  }
}
