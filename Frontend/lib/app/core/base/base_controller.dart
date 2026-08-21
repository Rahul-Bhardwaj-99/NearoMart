import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

abstract class BaseController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();

  void showLoading() => isLoading.value = true;
  void hideLoading() => isLoading.value = false;

  /// A wrapper for API calls that handles loading state and error messages.
  Future<T?> safeApiCall<T>(
    Future<T> Function() call, {
    bool showLoader = true,
    String? customErrorMessage,
    Function(dynamic error)? onError,
  }) async {
    try {
      if (showLoader) showLoading();
      errorMessage.value = null;
      return await call();
    } catch (e) {
      debugPrint('BaseController Error: $e');
      errorMessage.value = customErrorMessage ?? e.toString();
      if (onError != null) onError(e);
      return null;
    } finally {
      if (showLoader) hideLoading();
    }
  }
}
