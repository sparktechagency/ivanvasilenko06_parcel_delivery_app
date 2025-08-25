import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/termsNconditon/models/terms_and_conditon_models.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';

class TermsAndConditionController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  Rxn<TermsAndConditonModel> termsAndConditionData =
      Rxn<TermsAndConditonModel>();

  Future<void> getTheTermsandCondition() async {
    try {
      isLoading(true);
      hasError(false);
      var response =
          await ApiGetServices().apiGetServices(AppApiUrl.termAndCondtion);

      //! appLog("Terms API Response: $response");

      if (response != null) {
        // Try parsing the response directly first
        termsAndConditionData.value = TermsAndConditonModel.fromJson(response);
        //! appLog( "Terms data loaded: ${termsAndConditionData.value?.data?.content}");

        // Check if content is actually available
        if (termsAndConditionData.value?.data?.content == null ||
            termsAndConditionData.value!.data!.content!.isEmpty) {
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
    getTheTermsandCondition();
  }
}
