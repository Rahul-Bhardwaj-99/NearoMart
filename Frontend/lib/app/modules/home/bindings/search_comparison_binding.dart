import 'package:get/get.dart';
import '../controllers/search_comparison_controller.dart';

class SearchComparisonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchComparisonController>(() => SearchComparisonController());
  }
}
