import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_list_controller.dart';
import '../../../widgets/layout/custom_bottom_nav.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/strings.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';

class ChatListView extends GetView<ChatListController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppStrings.chats, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (controller.chats.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.refreshChats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 80.sp, color: Colors.grey.shade300),
                      SizedBox(height: 20.h),
                      Text(AppStrings.noConversations, style: TextStyle(fontSize: 18.sp, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.refreshChats(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            itemCount: controller.chats.length,
            itemBuilder: (context, index) {
              final chat = controller.chats[index];
              return _buildChatItem(chat);
            },
          ),
        );
      }),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Get.offAllNamed(Routes.HOME);
          if (index == 1) Get.offAllNamed(Routes.DISCOVER);
          if (index == 3) Get.offAllNamed(Routes.ORDERS);
          if (index == 4) Get.offAllNamed(Routes.PROFILE);
        },
      ),
    );
  }

  Widget _buildChatItem(dynamic chat) {
    final shop = chat['shopId'];
    final isClosed = chat['status'] == 'CLOSED';
    final updatedAt = DateTime.tryParse(chat['updatedAt']?.toString() ?? '');
    return ListTile(
      onTap: () => Get.toNamed(Routes.CHAT_DETAIL, arguments: ChatArguments.fromData(chat)),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 55.w,
        height: 55.w,
        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: shop['bannerUrl'] != null 
          ? ClipRRect(borderRadius: BorderRadius.circular(30.w), child: Image.network(shop['bannerUrl'], fit: BoxFit.cover))
          : Icon(Icons.store, color: AppColors.primary, size: 28.sp),
      ),
      title: Text(shop['shopName'] ?? 'Store Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isClosed)
            Text(AppStrings.chatEnded, style: TextStyle(color: Colors.red.shade700, fontSize: 12.sp, fontWeight: FontWeight.w600)),
          Text(
            isClosed ? AppStrings.chatReadOnly : (chat['lastMessage'] ?? AppStrings.chat),
            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            updatedAt == null ? '' : '${updatedAt.hour.toString().padLeft(2, '0')}:${updatedAt.minute.toString().padLeft(2, '0')}',
            style: TextStyle(color: Colors.grey, fontSize: 11.sp),
          ),
          if (isClosed)
            Icon(Icons.lock_outline, color: Colors.grey, size: 16.sp),
        ],
      ),
    );
  }
}
