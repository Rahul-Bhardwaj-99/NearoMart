import 'package:flutter/material.dart';
import 'package:nearomart/app/core/utils/size_config.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _getStatusColor(status);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: effectiveColor,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PLACED':
      case 'NEW':
        return Colors.orange;
      case 'ACCEPTED':
      case 'ACTIVE':
      case 'PREPARING':
        return Colors.blue;
      case 'DISPATCHED':
      case 'OUT_FOR_DELIVERY':
        return Colors.indigo;
      case 'DELIVERED':
      case 'COMPLETED':
      case 'DONE':
        return Colors.green;
      case 'CANCELLED':
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
