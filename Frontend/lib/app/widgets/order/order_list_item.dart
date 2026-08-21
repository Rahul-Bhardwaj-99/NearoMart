import 'package:flutter/material.dart';
import 'package:nearomart/app/core/utils/size_config.dart';
import 'package:nearomart/app/core/values/colors.dart';
import 'package:nearomart/app/widgets/common/common_text.dart';
import '../common/status_badge.dart';

class OrderListItem extends StatelessWidget {
  final dynamic order;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showShopName;
  final bool showCustomerName;

  const OrderListItem({
    super.key,
    required this.order,
    required this.onTap,
    this.trailing,
    this.showShopName = true,
    this.showCustomerName = false,
  });

  @override
  Widget build(BuildContext context) {
    final shop = order['shopId'] as Map<String, dynamic>?;
    final buyer = order['buyerId'] as Map<String, dynamic>?;
    final status = order['orderStatus'] ?? 'PLACED';

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.all(15.w),
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Icon(Icons.receipt_long, color: AppColors.primary, size: 24.sp),
        ),
        title: CommonText(
          showShopName 
              ? (shop?['shopName'] ?? 'NearoMart Shop')
              : (showCustomerName ? (buyer?['name'] ?? 'Customer') : 'Order #${order['orderNumber'] ?? ''}'),
          type: TextType.body,
          fontWeight: FontWeight.bold,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showShopName && showCustomerName)
              CommonText('To: ${buyer?['name'] ?? 'Customer'}', type: TextType.caption),
            SizedBox(height: 4.h),
            Row(
              children: [
                StatusBadge(status: status),
                SizedBox(width: 10.w),
                CommonText(
                  '₹${order['grandTotal'] ?? 0}',
                  type: TextType.body,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ],
        ),
        trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.textSecondary.withValues(alpha: 0.4)),
      ),
    );
  }
}
