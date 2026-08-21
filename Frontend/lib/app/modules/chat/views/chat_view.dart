import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../../../core/utils/size_config.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: AppColors.secondary, size: 24.sp), onPressed: () => Get.back()),
        title: Obx(() {
          final shop = controller.chatData['shopId'];
          return Row(
            children: [
              CircleAvatar(
                radius: 18.w, 
                backgroundColor: const Color(0xFFFFF3E0), 
                backgroundImage: shop != null && shop['bannerUrl'] != null ? NetworkImage(shop['bannerUrl']) : null,
                child: shop == null || shop['bannerUrl'] == null ? Icon(Icons.store, color: AppColors.primary, size: 20.sp) : null,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop != null ? shop['shopName'] : AppStrings.storeName, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  Row(
                    children: [
                      Container(width: 8.w, height: 8.w, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      SizedBox(width: 4.w),
                      Obx(() => Text(
                        controller.isEnded.value ? AppStrings.chatReadOnly : AppStrings.online,
                        style: TextStyle(
                          color: controller.isEnded.value ? Colors.grey : Colors.green,
                          fontSize: 12.sp,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          Obx(() => controller.isEnded.value
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: _confirmEndChat,
                  icon: Icon(Icons.stop_circle_outlined, color: Colors.red, size: 24.sp),
                  tooltip: AppStrings.endChat,
                )),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification && notification.metrics.pixels <= 80) {
                    controller.loadOlderMessages();
                  }
                  return false;
                },
                child: ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  // Determine if isMe based on senderRole or senderId (needs real userId)
                  final bool isMe = message['senderRole'] == 'BUYER';
                  
                  if (message['messageType'] == 'BARGAIN_REQUEST') {
                    return _buildBargainRequest(message);
                  }
                  
                  return _chatBubble(
                    message['content'] ?? '', 
                    '${DateTime.parse(message['timestamp']).hour}:${DateTime.parse(message['timestamp']).minute}', 
                    isMe
                  );
                },
                ),
              );
            }),
          ),
          Obx(() => controller.isEnded.value ? _buildEndedBanner() : _buildChatInput()),
        ],
      ),
    );
  }

  Widget _buildBargainRequest(dynamic message) {
    return Container(
      margin: EdgeInsets.only(bottom: 25.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20.w), border: Border.all(color: Colors.purple.shade100, width: 1.w)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.handshake_outlined, color: Colors.purple, size: 24.sp),
              SizedBox(width: 10.w),
              Text(AppStrings.bargainRequest, style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, letterSpacing: 1.w, fontSize: 12.sp)),
            ],
          ),
          SizedBox(height: 15.h),
          Text(message['content'] ?? 'Customer is asking for discount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 15.h),
          Text(
            'Offer: ₹${message['metadata']?['offerAmount'] ?? '--'}'
            '${message['metadata']?['counterAmount'] != null ? ' • Counter: ₹${message['metadata']['counterAmount']}' : ''}',
            style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            'Status: ${message['metadata']?['status'] ?? 'PENDING'}',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp),
          ),
          if (!controller.isEnded.value) ...[
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bargainAction(AppStrings.reject, Colors.grey, () => controller.updateBargain(message['_id'] ?? message['messageId'], 'REJECTED')),
                _bargainAction(AppStrings.counterOffer, Colors.blue, () => _showCounterOffer(message)),
                _bargainAction(AppStrings.accept, Colors.green, () => controller.updateBargain(message['_id'] ?? message['messageId'], 'ACCEPTED')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _bargainAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.w), border: Border.all(color: color.withValues(alpha: 0.3), width: 1.w)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12.sp)),
      ),
    );
  }

  void _showCounterOffer(dynamic message) {
    final amountController = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text(AppStrings.counterOfferTitle),
      content: TextField(
        controller: amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(prefixText: '₹ ', hintText: AppStrings.amount),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text(AppStrings.cancel)),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              Get.back();
              controller.updateBargain(message['_id'] ?? message['messageId'], 'COUNTERED', counterAmount: amount);
            }
          },
          child: const Text(AppStrings.send),
        ),
      ],
    ));
  }

  Widget _chatBubble(String msg, String time, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(15.w),
        constraints: BoxConstraints(maxWidth: 280.w),
        decoration: BoxDecoration(color: isMe ? AppColors.primary : Colors.grey.shade100, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.w), topRight: Radius.circular(20.w), bottomLeft: Radius.circular(isMe ? 20.w : 0), bottomRight: Radius.circular(isMe ? 0 : 20.w))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14.sp)),
            SizedBox(height: 5.h),
            Text(time, style: TextStyle(color: isMe ? Colors.white60 : Colors.grey, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
      child: Row(
        children: [
          Icon(Icons.attachment_outlined, color: Colors.grey, size: 24.sp),
          SizedBox(width: 15.w),
          IconButton(
            onPressed: () => _showBargainDialog(),
            icon: Icon(Icons.handshake_outlined, color: Colors.purple, size: 24.sp),
            tooltip: 'Make an offer',
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15.w)),
              child: TextField(
                controller: controller.messageController,
                style: TextStyle(fontSize: 14.sp),
                decoration: const InputDecoration(hintText: AppStrings.typeMessage, border: InputBorder.none)
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Icon(Icons.mic_none_outlined, color: Colors.grey, size: 24.sp),
          SizedBox(width: 15.w),
          GestureDetector(
            onTap: () => controller.sendMessage(),
            child: Container(padding: EdgeInsets.all(12.w), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Icon(Icons.send, color: Colors.white, size: 20.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildEndedBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          const Text(AppStrings.chatSessionEnded, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          const Text(AppStrings.chatSessionEndedDesc, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _confirmEndChat() {
    Get.dialog(AlertDialog(
      title: const Text(AppStrings.endChat),
      content: const Text(AppStrings.endChatConfirm),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.endChat();
          },
          child: const Text(AppStrings.endChat),
        ),
      ],
    ));
  }

  void _showBargainDialog() {
    final amountController = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('Make an offer'),
      content: TextField(
        controller: amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(prefixText: '₹ ', hintText: 'Your offer'),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              Get.back();
              controller.sendBargain(amount);
            }
          },
          child: const Text('Send offer'),
        ),
      ],
    ));
  }
}
