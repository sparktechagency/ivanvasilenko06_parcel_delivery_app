import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/privacy_policy/model/privacy_policy_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';

class PrivacyPolicyController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  Rxn<PrivacyPolicyModel> privacyPolicyData = Rxn<PrivacyPolicyModel>();
  @override
  void onInit() {
    super.onInit();
    getPrivacyPolicy();
  }

  Future<void> getPrivacyPolicy() async {
    try {
      isLoading(true);
      hasError(false);
      var response =
          await ApiGetServices().apiGetServices(AppApiUrl.privacyPolicy);

      //! appLog("Terms API Response: $response");

      if (response != null) {
        // Try parsing the response directly first
        privacyPolicyData.value = PrivacyPolicyModel.fromJson(response);
        //! appLog( "Terms data loaded: ${termsAndConditionData.value?.data?.content}");

        // Check if content is actually available
        if (privacyPolicyData.value?.data?.content == null ||
            privacyPolicyData.value!.data!.content!.isEmpty) {
          hasError(true);
        }
      } else {
        hasError(true);
      }
    } catch (e) {
      //! appLog("Error loading terms: ${e.toString()}");
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void refreshTerms() {
    getPrivacyPolicy();
  }
}
