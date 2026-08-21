import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';
import '../controllers/merchant_dashboard_controller.dart';
import '../../../widgets/layout/base_scaffold.dart';
import '../../../widgets/layout/dashboard_components.dart';
import '../../../widgets/profile/profile_components.dart';
import '../../../widgets/common/common_text.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';
import 'package:intl/intl.dart';

import 'package:fl_chart/fl_chart.dart';

class MerchantDashboardView extends GetView<MerchantDashboardController> {
  const MerchantDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseScaffold(
      showAppBar: false,
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: [
          _buildDashboardHome(),
          _buildOrderManagement(),
          _buildInventoryManagement(),
          _buildAnalytics(),
          _buildProfile(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    ));
  }

  // --- TAB 0: DASHBOARD HOME ---
  Widget _buildDashboardHome() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => controller.fetchDashboardStats(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildStatsGrid(),
              _buildNewOrdersSection(),
              _buildManagementSuite(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.w),
          bottomRight: Radius.circular(30.w),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(AppStrings.merchantDashboard, type: TextType.caption, color: AppColors.surface.withValues(alpha: 0.6)),
                    Obx(
                      () => CommonText(
                        controller.shopName.value,
                        type: TextType.title,
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 2.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Obx(
                () => CircleAvatar(
                  radius: 20.w,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    controller.shopName.value.isNotEmpty
                        ? controller.shopName.value[0]
                        : 'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      AppStrings.homeDelivery,
                      type: TextType.caption,
                      color: AppColors.surface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                    ),
                    Obx(
                      () => Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: controller.isDeliveryOn.value
                                ? AppColors.success
                                : AppColors.error,
                            size: 10.sp,
                          ),
                          SizedBox(width: 8.w),
                          CommonText(
                            controller.isDeliveryOn.value
                                ? AppStrings.deliveryOn
                                : AppStrings.deliveryOff,
                            type: TextType.body,
                            color: controller.isDeliveryOn.value
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => Switch(
                    value: controller.isDeliveryOn.value,
                    onChanged: (val) => controller.toggleDelivery(val),
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: EdgeInsets.all(25.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => StatCard(
              value: '₹${NumberFormat('#,###').format(controller.todayRevenue.value)}',
              label: AppStrings.todayRevenue,
              subtitle: '+12%',
              color: Colors.green,
            ),
          ),
          Obx(
            () => StatCard(
              value: '${controller.totalOrders.value}',
              label: AppStrings.orders,
              subtitle: '${controller.pendingOrders.value} pending',
              color: Colors.orange,
            ),
          ),
          Obx(
            () => StatCard(
              value: '${controller.shopRating.value}★',
              label: AppStrings.rating,
              subtitle: '${controller.reviewCount.value} reviews',
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrdersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  CommonText(
                    AppStrings.newOrders,
                    type: TextType.title,
                  ),
                ],
              ),
              TextButton(
                onPressed: () => controller.changeTab(1),
                child: CommonText(
                  AppStrings.viewAll,
                  type: TextType.caption,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.orders.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: CommonText(
                  'No new orders',
                  type: TextType.body,
                  color: AppColors.textSecondary,
                ),
              );
            }
            final newOrders = controller.orders
                .where((o) => o['orderStatus'] == 'PLACED')
                .take(2)
                .toList();
            return Column(
              children: newOrders
                  .map(
                    (order) => _orderItem(
                      order['_id'],
                      order['orderNumber'],
                      order['items'].map((i) => i['productName']).join(', '),
                      '₹${order['grandTotal']}',
                      'Just now',
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _orderItem(
    String id,
    String orderNo,
    String desc,
    String price,
    String time,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(orderNo, type: TextType.body, fontWeight: FontWeight.bold),
                    CommonText(time, type: TextType.caption),
                  ],
                ),
                CommonText(
                  desc,
                  type: TextType.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),
                CommonText(
                  price,
                  type: TextType.title,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          SizedBox(width: 15.w),
          Column(
            children: [
              OutlinedButton(
                onPressed: () => controller.updateOrderStatus(id, 'CANCELLED'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(80.w, 35.h),
                  side: const BorderSide(color: AppColors.error),
                ),
                child: CommonText(
                  AppStrings.reject,
                  type: TextType.caption,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 8.h),
              ElevatedButton(
                onPressed: () => controller.updateOrderStatus(id, 'ACCEPTED'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: Size(80.w, 35.h),
                ),
                child: CommonText(
                  AppStrings.accept,
                  type: TextType.caption,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSuite() {
    return Padding(
      padding: EdgeInsets.all(25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            AppStrings.managementSuite,
            type: TextType.title,
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              QuickActionItem(
                label: AppStrings.inventory,
                icon: Icons.inventory_2_outlined,
                bgColor: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF2196F3),
                onTap: () => controller.changeTab(2),
              ),
              SizedBox(width: 15.w),
              QuickActionItem(
                label: AppStrings.marketing,
                icon: Icons.campaign_outlined,
                bgColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF4CAF50),
                onTap: () => Get.toNamed(Routes.MERCHANT_MARKETING),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              QuickActionItem(
                label: AppStrings.analytics,
                icon: Icons.bar_chart_outlined,
                bgColor: const Color(0xFFFFF3E0),
                iconColor: AppColors.primary,
                onTap: () => controller.changeTab(3),
              ),
              SizedBox(width: 15.w),
              QuickActionItem(
                label: AppStrings.storeProfile,
                icon: Icons.settings_outlined,
                bgColor: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9C27B0),
                onTap: () => controller.changeTab(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 1: ORDER MANAGEMENT ---
  Widget _buildOrderManagement() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => controller.changeTab(0),
                  child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
                SizedBox(width: 15.w),
                CommonText(
                  'Order Management',
                  type: TextType.title,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15.w),
              ),
              child: Row(
                children: [
                  _filterBtn('New', 'NEW'),
                  _filterBtn('Active', 'ACTIVE'),
                  _filterBtn('Done', 'DONE'),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  return _buildDetailedOrderCard(order);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, String value) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.orderFilter.value == value;
        return GestureDetector(
          onTap: () => controller.setOrderFilter(value),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12.w),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: CommonText(
                label,
                type: TextType.body,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailedOrderCard(dynamic order) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                order['orderNumber'],
                type: TextType.body,
                fontWeight: FontWeight.bold,
              ),
              CommonText(
                '₹${order['grandTotal']}',
                type: TextType.title,
                color: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 5.h),
          CommonText(
            '${order['buyerId']?['name'] ?? 'Customer'} • 2 min ago',
            type: TextType.caption,
          ),
          Divider(height: 30.h),
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: Colors.blue,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CommonText(
                  order['items']
                      .map((i) => '${i['quantity']}x ${i['productName']}')
                      .join(', '),
                  type: TextType.body,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.error, size: 18.sp),
              SizedBox(width: 10.w),
              CommonText('House 102, Sec 17', type: TextType.body),
              // Should be dynamic
            ],
          ),
          if (controller.orderFilter.value == 'NEW') ...[
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        controller.updateOrderStatus(order['_id'], 'CANCELLED'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const CommonText(
                      'Reject',
                      type: TextType.body,
                      color: AppColors.error,
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.updateOrderStatus(order['_id'], 'ACCEPTED'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      backgroundColor: AppColors.success,
                    ),
                    child: const CommonText(
                      'Accept Order',
                      type: TextType.body,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 2: INVENTORY ---
  Widget _buildInventoryManagement() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  'Inventory',
                  type: TextType.header,
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.MERCHANT_ADD_PRODUCT),
                  icon: Icon(Icons.add, color: AppColors.surface, size: 20),
                  label: CommonText(
                    'Add Product',
                    type: TextType.caption,
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15.w),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.textSecondary),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                        border: InputBorder.none,
                        isDense: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          SizedBox(
            height: 45.h,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  _inventoryFilter(
                    'All (${controller.inventoryStats['all']})',
                    'ALL',
                  ),
                  _inventoryFilter(
                    'In Stock (${controller.inventoryStats['inStock']})',
                    'IN_STOCK',
                  ),
                  _inventoryFilter(
                    'Low Stock (${controller.inventoryStats['lowStock']})',
                    'LOW_STOCK',
                  ),
                  _inventoryFilter(
                    'Out of Stock (${controller.inventoryStats['outOfStock']})',
                    'OUT_OF_STOCK',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.inventory.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64.sp,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No products found',
                        style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: controller.inventory.length,
                itemBuilder: (context, index) {
                  final product = controller.inventory[index];
                  return _buildInventoryItem(product);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _inventoryFilter(String label, String value) {
    return Obx(() {
      final isSelected = controller.inventoryFilter.value == value;
      return GestureDetector(
        onTap: () {
          controller.inventoryFilter.value = value;
          controller.fetchInventory();
        },
        child: Container(
          margin: EdgeInsets.only(right: 10.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
            ),
          ),
          child: Center(
            child: CommonText(
              label,
              type: TextType.caption,
              color: isSelected ? AppColors.surface : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInventoryItem(dynamic product) {
    final int stock = product['stockQuantity'] ?? 0;
    Color stockColor = Colors.green;
    String stockText = '$stock left';
    IconData stockIcon = Icons.check_circle_outline;

    if (stock == 0) {
      stockColor = AppColors.error;
      stockText = 'Out of Stock';
      stockIcon = Icons.cancel_outlined;
    } else if (stock <= 5) {
      stockColor = AppColors.primary;
      stockText = '$stock left';
      stockIcon = Icons.warning_amber_rounded;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(15.w),
            ),
            child: product['imageUrl'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15.w),
                    child: Image.network(
                      product['imageUrl'],
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 30.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  product['name'] ?? 'Product Name',
                  type: TextType.body,
                  fontWeight: FontWeight.bold,
                ),
                CommonText(
                  '${product['category']} • ${product['unit']}',
                  type: TextType.caption,
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    CommonText(
                      '₹${product['price']}',
                      type: TextType.body,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Row(
                        children: [
                          Icon(stockIcon, color: stockColor, size: 12.sp),
                          SizedBox(width: 4.w),
                          CommonText(
                            stockText,
                            type: TextType.caption,
                            color: stockColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to Edit screen with product data
                  Get.toNamed(Routes.MERCHANT_ADD_PRODUCT, arguments: ProductArguments.fromData(product));
                },
                child: CommonText(
                  'Edit',
                  type: TextType.caption,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (stock == 0)
                TextButton(
                  onPressed: () =>
                      controller.restockProduct(product['_id'], 50),
                  child: CommonText(
                    'Restock',
                    type: TextType.caption,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              IconButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Delete Product',
                    middleText: 'Are you sure you want to delete this product?',
                    onConfirm: () {
                      controller.deleteProduct(product['_id']);
                      Get.back();
                    },
                    onCancel: () {},
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 3: ANALYTICS ---
  Widget _buildAnalytics() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => controller.changeTab(0),
                  child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
                SizedBox(width: 15.w),
                CommonText(
                  'Analytics',
                  type: TextType.header,
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Row(
                    children: [
                      CommonText(
                        'This Week',
                        type: TextType.caption,
                        fontWeight: FontWeight.bold,
                      ),
                      Icon(Icons.keyboard_arrow_down, size: 16.sp, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            _buildWeeklyRevenueChart(),
            SizedBox(height: 30.h),
            Row(
              children: [
                _miniStatCard(
                  '156',
                  'Total Orders',
                  '+23 this week',
                  Colors.orange,
                ),
                SizedBox(width: 15.w),
                _miniStatCard(
                  '₹182',
                  'Avg Order Value',
                  '+₹12 vs last wk',
                  Colors.green,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildOrderSplitSection(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyRevenueChart() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            'Weekly Revenue',
            type: TextType.caption,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 5.h),
          Obx(() {
            double total = 0;
            for (var item in controller.weeklyRevenue) {
              total += (item['revenue'] ?? 0).toDouble();
            }
            return CommonText(
              '₹${NumberFormat('#,###').format(total)}',
              type: TextType.header,
              color: AppColors.primary,
            );
          }),
          Row(
            children: [
              Icon(Icons.arrow_upward, color: AppColors.success, size: 14.sp),
              CommonText(
                ' +18.4% vs last week',
                type: TextType.caption,
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 30.h),
          AspectRatio(
            aspectRatio: 1.7,
            child: Obx(() {
              if (controller.weeklyRevenue.isEmpty) {
                return Center(child: CommonText('No data for this week', type: TextType.body));
              }
              return BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          if (val < 0 || val >= controller.weeklyRevenue.length) {
                            return const Text('');
                          }
                          final dateStr =
                              controller.weeklyRevenue[val.toInt()]['_id'];
                          final date = DateTime.parse(dateStr);
                          return CommonText(
                            DateFormat('E').format(date),
                            type: TextType.caption,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: controller.weeklyRevenue.asMap().entries.map((
                    entry,
                  ) {
                    return _barGroup(
                      entry.key,
                      (entry.value['revenue'] ?? 0).toDouble(),
                      entry.key == controller.weeklyRevenue.length - 1,
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, bool isSelected) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.2),
          width: 25.w,
          borderRadius: BorderRadius.circular(8.w),
        ),
      ],
    );
  }

  Widget _miniStatCard(String val, String label, String trend, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(25.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              val,
              type: TextType.title,
              fontWeight: FontWeight.bold,
            ),
            CommonText(
              label,
              type: TextType.caption,
            ),
            SizedBox(height: 10.h),
            CommonText(
              trend,
              type: TextType.caption,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSplitSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.delivery_dining, color: Colors.pink, size: 30.sp),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  '89 (57%)',
                  type: TextType.title,
                  fontWeight: FontWeight.bold,
                ),
                CommonText(
                  'Delivery Orders',
                  type: TextType.caption,
                ),
                CommonText(
                  'vs 67 Pickup',
                  type: TextType.caption,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          Container(width: 1.w, height: 40.h, color: AppColors.background),
          SizedBox(width: 15.w),
          Icon(
            Icons.account_balance_outlined,
            color: Colors.indigo,
            size: 30.sp,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  '₹4,280',
                  type: TextType.title,
                  fontWeight: FontWeight.bold,
                ),
                CommonText(
                  'Pending Payouts',
                  type: TextType.caption,
                ),
                CommonText(
                  'Expected in 24h',
                  type: TextType.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: PROFILE ---
  Widget _buildProfile() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              'Settings & Profile',
              type: TextType.header,
            ),
            SizedBox(height: 30.h),
            Obx(() => ProfileHeader(
              name: controller.shopName.value,
              subtitle: controller.shopId.value.isNotEmpty ? 'Merchant ID: ${controller.shopId.value.substring(0, 8)}...' : '',
              initial: controller.shopName.value.isNotEmpty ? controller.shopName.value[0] : 'S',
            )),
            SizedBox(height: 30.h),
            _buildQrSection(),
            SizedBox(height: 25.h),
            _buildBroadcastSection(),
            SizedBox(height: 25.h),
            ProfileMenuItem(
              icon: Icons.store_outlined,
              title: 'Edit Shop Profile',
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.verified_user_outlined,
              title: 'KYC Verification',
              onTap: () => Get.toNamed(Routes.MERCHANT_KYC),
            ),
            ProfileMenuItem(
              icon: Icons.history,
              title: 'Order History',
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => controller.logout(),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection() {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Colors.deepPurple,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              CommonText(
                'Shop Counter QR Code',
                type: TextType.body,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          CommonText(
            'Customers scan to open your shop & chat instantly',
            type: TextType.caption,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 25.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C2E),
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Icon(Icons.qr_code_2, color: AppColors.surface, size: 150.sp),
          ),
          SizedBox(height: 20.h),
          Obx(
            () => CommonText(
              controller.shopName.value,
              type: TextType.body,
              fontWeight: FontWeight.bold,
            ),
          ),
          CommonText(
            'Main Market, Dharamshala, HP',
            type: TextType.caption,
          ),
          SizedBox(height: 25.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.print_outlined, color: AppColors.surface),
                  label: CommonText(
                    'Print PDF',
                    type: TextType.caption,
                    color: AppColors.surface,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.download_outlined,
                    color: AppColors.primary,
                  ),
                  label: CommonText(
                    'Download',
                    type: TextType.caption,
                    color: AppColors.primary,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastSection() {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign_outlined, color: Colors.pink, size: 24.sp),
              SizedBox(width: 10.w),
              CommonText(
                'Broadcast Notification',
                type: TextType.body,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          CommonText(
            'Send push alert to all 234 followers',
            type: TextType.caption,
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(15.w),
              border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller.broadcastController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Type your announcement... (e.g. 20% OFF on all Dairy products today!)',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.4),
                  fontSize: 13.sp,
                ),
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          SizedBox(height: 15.h),
          ElevatedButton(
            onPressed: () => controller.broadcastMessage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 50.h),
            ),
            child: CommonText(
              'Send Broadcast',
              type: TextType.body,
              color: AppColors.surface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
