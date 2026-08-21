import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/strings.dart';
import '../../../core/values/colors.dart';
import '../controllers/shop_kyc_controller.dart';

class ShopKycView extends GetView<ShopKycController> {
  const ShopKycView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<ShopKycController>()) {
      Get.put(ShopKycController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => controller.prevStep(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.merchantOnboarding,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              AppStrings.shopKycSetup,
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Obx(() => Column(
        children: [
          const SizedBox(height: 20),
          _buildStepIndicator(),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: _buildStepContent(),
            ),
          ),
          _buildBottomButtons(),
        ],
      )),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          _indicatorItem(0, AppStrings.shopInfo),
          _indicatorLine(0),
          _indicatorItem(1, AppStrings.documents),
          _indicatorLine(1),
          _indicatorItem(2, AppStrings.bankDetails),
        ],
      ),
    );
  }

  Widget _indicatorItem(int step, String label) {
    final isActive = controller.currentStep.value >= step;
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicatorLine(int step) {
    return const SizedBox(width: 10);
  }

  Widget _buildStepContent() {
    switch (controller.currentStep.value) {
      case 0: return _buildShopInfoStep();
      case 1: return _buildDocumentsStep();
      case 2: return _buildBankDetailsStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildShopInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Upload
        GestureDetector(
          onTap: controller.pickBanner,
          child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), style: BorderStyle.none),
          ),
          child: Obx(() => controller.selectedBanner.value == null
            ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_outlined, size: 50, color: AppColors.primary),
              const SizedBox(height: 12),
              const Text(
                AppStrings.uploadShopPhoto,
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                AppStrings.uploadShopPhotoDesc,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
            )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(controller.selectedBanner.value!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              )),
          ),
        ),
        const SizedBox(height: 30),
        _buildTextField(AppStrings.shopName, AppStrings.shopNameHint, controller.shopNameController),
        _buildTextField(AppStrings.shopCategory, AppStrings.shopCategoryHint, controller.shopCategoryController),
        _buildTextField(AppStrings.shopAddress, AppStrings.shopAddressHint, controller.shopAddressController, maxLines: 3),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocUploadCard(AppStrings.gstinNumber, 'GSTIN Number', Icons.account_balance_outlined, controller.gstinController),
        _buildDocUploadCard(AppStrings.fssaiLicense, 'FSSAI License', Icons.security_outlined, controller.fssaiController),
        _buildDocUploadCard(AppStrings.drugLicense, 'Drug License (if pharma)', Icons.medication_outlined, controller.drugLicenseController),
      ],
    );
  }

  Widget _buildBankDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(AppStrings.accountHolderName, 'e.g. Ramesh Sharma', controller.accountHolderNameController),
        _buildTextField(AppStrings.bankName, 'e.g. State Bank of India', controller.bankNameController),
        _buildTextField(AppStrings.accountNumber, 'XXXXXXXX8921', controller.accountNumberController),
        _buildTextField(AppStrings.ifscCode, 'SBIN0001234', controller.ifscCodeController),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.1)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.teal, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.bankSecurityNote,
                  style: TextStyle(color: Colors.teal, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController textController, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF607D8B), fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: textController,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.grey.shade50,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocUploadCard(String label, String hint, IconData icon, TextEditingController textController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.secondary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14)
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  AppStrings.upload,
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Row(
        children: [
          if (controller.currentStep.value > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.prevStep(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text(AppStrings.back, style: TextStyle(color: AppColors.textPrimary)),
              ),
            ),
            const SizedBox(width: 15),
          ],
          Expanded(
            flex: 2,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.nextStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: controller.isLoading.value 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    controller.currentStep.value == 2 ? AppStrings.submitForReview : AppStrings.continueArrow,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
            )),
          ),
        ],
      ),
    );
  }
}
