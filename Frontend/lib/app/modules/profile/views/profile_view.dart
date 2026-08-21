import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../widgets/layout/base_scaffold.dart';
import '../../../widgets/profile/profile_components.dart';
import '../../../widgets/profile/profile_menu_list.dart';
import '../../../widgets/layout/custom_bottom_nav.dart';
import '../../../core/values/app_sizes.dart';
import '../../../core/values/strings.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/arguments/arguments.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseScaffold(
      title: AppStrings.profile,
      isLoading: controller.isLoading.value,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            final user = controller.currentUser.value;
            Get.toNamed(
              Routes.EDIT_PROFILE,
              arguments: EditProfileArguments(
                name: user?.name ?? '',
                phone: user?.phone ?? '',
                email: user?.email ?? '',
                profilePic: user?.profilePic ?? '',
              ),
            )?.then((value) {
              if (value == true) controller.fetchProfile();
            });
          },
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSizes.spacingXl),
            Obx(() {
              final user = controller.currentUser.value;
              return ProfileHeader(
                name: user?.name ?? 'Set Name',
                subtitle: user?.phone ?? '',
                profilePic: user?.profilePic,
                initial: controller.userService.userNameInitial,
              );
            }),
            SizedBox(height: AppSizes.spacingXxl + 6.h),
            ProfileMenuList(
              entries: [
                ProfileMenuEntry(
                  icon: Icons.location_on_outlined,
                  title: AppStrings.myAddresses,
                  onTap: () => Get.toNamed(Routes.SAVED_ADDRESSES),
                ),
                ProfileMenuEntry(
                  icon: Icons.chat_bubble_outline,
                  title: AppStrings.myChats,
                  onTap: () => Get.toNamed(Routes.CHAT),
                ),
                ProfileMenuEntry(
                  icon: Icons.history,
                  title: AppStrings.orderHistory,
                  onTap: () => Get.toNamed(Routes.ORDERS),
                ),
                ProfileMenuEntry(
                  icon: Icons.notifications_none,
                  title: AppStrings.notifications,
                  onTap: () {},
                ),
                ProfileMenuEntry(
                  icon: Icons.help_outline,
                  title: AppStrings.helpSupport,
                  onTap: () {},
                ),
                ProfileMenuEntry(
                  icon: Icons.logout,
                  title: AppStrings.logout,
                  onTap: () => controller.logout(),
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Get.offAllNamed(Routes.HOME);
          if (index == 1) Get.offAllNamed(Routes.DISCOVER);
          if (index == 2) Get.toNamed(Routes.SEARCH_COMPARISON);
          if (index == 4) Get.toNamed(Routes.CART);
        },
      ),
    ));
  }
}
