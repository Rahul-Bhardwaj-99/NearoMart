import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';
import '../controllers/rider_dashboard_controller.dart';
import '../../../widgets/layout/base_scaffold.dart';
import '../../../widgets/layout/dashboard_components.dart';
import '../../../widgets/profile/profile_components.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/common_text.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';
import 'package:intl/intl.dart';

class RiderDashboardView extends GetView<RiderDashboardController> {
  const RiderDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseScaffold(
      showAppBar: false,
      backgroundColor: Colors.grey.shade50,
      isLoading: controller.isLoading.value,
      body: Stack(
        children: [
          IndexedStack(
            index: controller.currentIndex.value,
            children: [
              _buildHomeTab(),
              _buildNavigationTab(),
              _buildHistoryTab(),
              _buildProfileTab(),
            ],
          ),
          _buildDispatchOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    ));
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: controller.fetchEverything,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsRow(),
            _buildActiveOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(25.w, 60.h, 25.w, 30.h),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
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
                    CommonText(AppStrings.riderApp, type: TextType.caption, color: AppColors.surface.withValues(alpha: 0.6)),
                    Obx(() => CommonText(
                      controller.userProfile.value?.name ?? AppStrings.riderApp,
                      type: TextType.header,
                      color: AppColors.surface,
                    )),
                  ],
                ),
              ),
              Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: (controller.isOnline.value ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.w),
                  border: Border.all(color: controller.isOnline.value ? AppColors.success : AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: controller.isOnline.value ? AppColors.success : AppColors.error, size: 8.sp),
                    SizedBox(width: 8.w),
                    CommonText(
                      controller.isOnline.value ? 'Online' : 'Offline',
                      type: TextType.caption,
                      color: controller.isOnline.value ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              )),
              SizedBox(width: 15.w),
              CircleAvatar(
                radius: 22.w,
                backgroundColor: AppColors.primary,
                child: Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ),
            ],
          ),
          SizedBox(height: 25.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(AppStrings.availableForDeliveries, type: TextType.body, color: AppColors.surface),
              Obx(() => Switch(
                value: controller.isOnline.value, 
                onChanged: controller.toggleOnline,
                activeTrackColor: AppColors.success,
                activeThumbColor: AppColors.surface,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.all(25.w),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatCard(
            value: '₹${controller.stats['todayEarnings']}',
            label: AppStrings.todayEarned,
            color: AppColors.success,
          ),
          StatCard(
            value: '${controller.stats['todayDeliveries']}',
            label: 'Deliveries',
            color: AppColors.primary,
          ),
          StatCard(
            value: '${controller.stats['rating']}★',
            label: 'Rating',
            color: Colors.blue,
          ),
        ],
      )),
    );
  }

  Widget _buildActiveOrdersList() {
    return Obx(() {
      if (controller.activeDeliveries.isEmpty) {
        return _buildEmptyState('No active orders', Icons.assignment_outlined);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: CommonText(AppStrings.currentDeliveries, type: TextType.title, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          ...controller.activeDeliveries.map((order) => _buildOrderCard(order)),
        ],
      );
    });
  }

  Widget _buildOrderCard(dynamic order) {
    return Container(
      margin: EdgeInsets.fromLTRB(25.w, 0, 25.w, 15.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50.w, height: 50.w,
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15.w)),
                child: Icon(Icons.delivery_dining, color: Colors.orange, size: 24.sp),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(order['shopId']?['shopName'] ?? 'Store', type: TextType.body, fontWeight: FontWeight.bold),
                    CommonText(order['orderNumber'] ?? '', type: TextType.caption),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.w)),
                child: CommonText(AppStrings.active, type: TextType.caption, color: AppColors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          const Divider(),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _orderInfo('Order Value', '₹${order['grandTotal']}'),
              _orderInfo('Your Earnings', '₹${order['riderEarnings'] ?? 40}'),
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.RIDER_NAVIGATION, arguments: RiderOrderArguments.fromData(order)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                ),
                child: CommonText('Navigate', type: TextType.caption, color: AppColors.surface),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(label, type: TextType.caption),
        CommonText(value, type: TextType.body, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildNavigationTab() {
    return Obx(() {
      if (controller.activeDeliveries.isEmpty) {
        return _buildEmptyState('No active delivery to navigate', Icons.map_outlined);
      }
      // If there are active deliveries, show the list with navigation action
      return SingleChildScrollView(
        padding: EdgeInsets.only(top: 60.h),
        child: Column(
          children: [
             Padding(
              padding: EdgeInsets.all(25.w),
              child: CommonText(AppStrings.activeShipments, type: TextType.header),
            ),
            ...controller.activeDeliveries.map((order) => _buildOrderCard(order)),
          ],
        ),
      );
    });
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(25.w, 60.h, 25.w, 20.h),
          color: AppColors.surface,
          child: Row(
            children: [
              CommonText(AppStrings.deliveryHistory, type: TextType.header),
              const Spacer(),
              Icon(Icons.filter_list, size: 24.sp, color: AppColors.textPrimary),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.historyDeliveries.isEmpty) {
              return _buildEmptyState('No past deliveries', Icons.history);
            }
            return ListView.builder(
              padding: EdgeInsets.all(25.w),
              itemCount: controller.historyDeliveries.length,
              itemBuilder: (context, index) {
                final order = controller.historyDeliveries[index];
                return _buildHistoryItem(order);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(dynamic order) {
    final date = DateTime.parse(order['createdAt']);
    final formattedDate = DateFormat('dd MMM, hh:mm a').format(date);

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.w),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(order['shopId']?['shopName'] ?? 'Store', type: TextType.body, fontWeight: FontWeight.bold),
                CommonText(formattedDate, type: TextType.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CommonText('+₹${order['riderEarnings'] ?? 0}', type: TextType.body, color: AppColors.success, fontWeight: FontWeight.bold),
              CommonText('Earned', type: TextType.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Obx(() => ProfileHeader(
            name: controller.userProfile.value?.name ?? AppStrings.riderApp,
            subtitle: controller.userProfile.value?.phone ?? '',
            profilePic: controller.userProfile.value?.profilePic,
            initial: 'R', // Should get from controller
          )),
          SizedBox(height: 30.h),
          Obx(() => WalletWidget(
            balance: '${controller.wallet['balance']}',
            onWithdraw: () {},
          )),
          SizedBox(height: 20.h),
          _buildProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.w)),
      child: Column(
        children: [
          ProfileMenuItem(icon: Icons.star_outline, title: 'Reviews & Ratings', onTap: () {}),
          ProfileMenuItem(icon: Icons.account_balance_outlined, title: 'Bank Details', onTap: () {}),
          ProfileMenuItem(icon: Icons.directions_bike_outlined, title: 'Vehicle Information', onTap: () {}),
          ProfileMenuItem(icon: Icons.verified_user_outlined, title: 'KYC Verification', onTap: () {}),
          const Divider(),
          ProfileMenuItem(icon: Icons.logout, title: 'Logout', onTap: controller.logout, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return EmptyStateWidget(title: text, icon: icon);
  }

  Widget _buildDispatchOverlay() {
    return Obx(() {
      final dispatch = controller.pendingDispatch.value;
      if (dispatch == null) return const SizedBox.shrink();

      return Container(
        color: Colors.black.withValues(alpha: 0.7),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(25.w),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(25.w),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(30.w)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15.w)),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.primary, size: 14.sp),
                          SizedBox(width: 5.w),
                          CommonText('NEW DISPATCH', type: TextType.caption, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ],
                      ),
                    ),
                    const Spacer(),
                    CommonText('0:28 to respond', type: TextType.caption),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Container(
                      width: 60.w, height: 60.w,
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(15.w)),
                      child: Icon(Icons.store, size: 30.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(dispatch['shopName'], type: TextType.title, fontWeight: FontWeight.bold),
                          CommonText('Pickup: ${dispatch['pickupAddress']}', type: TextType.caption),
                          CommonText('📍 0.6 km from you', type: TextType.caption, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(15.w)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home_outlined, color: AppColors.textSecondary, size: 16.sp),
                          SizedBox(width: 10.w),
                          Expanded(child: CommonText(dispatch['dropoffAddress'], type: TextType.body)),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      CommonText('1.8 km from store • Est. 12 min', type: TextType.caption),
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dispatchMetric('Order Value', '₹${dispatch['orderValue']}'),
                    _dispatchMetric('Your Earnings', '₹${dispatch['riderEarnings']}', color: AppColors.success),
                    _dispatchMetric('Total Distance', '${dispatch['totalDistance']} km'),
                  ],
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.declineDispatch,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: CommonText('Decline', type: TextType.body, color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.acceptDispatch(dispatch['orderId']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                        ),
                        child: CommonText('Accept Dispatch', type: TextType.body, color: AppColors.surface, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _dispatchMetric(String label, String value, {Color? color}) {
    return Column(
      children: [
        CommonText(label, type: TextType.caption),
        SizedBox(height: 4.h),
        CommonText(value, type: TextType.body, fontWeight: FontWeight.bold, color: color),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Obx(() => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      currentIndex: controller.currentIndex.value,
      onTap: controller.changeTab,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.navigation_outlined), label: 'Navigate'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ));
  }
}
