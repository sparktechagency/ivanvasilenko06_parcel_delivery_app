import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/termsNconditon/models/terms_and_conditon_models.dart';

class TermsAndConditionController extends GetxController{
  RxBool isLoading = false.obs;
  var termsAndConditionData = Rxn<TermsAndConditonModel>().obs;


  Future<void> getTheTermsandCondition() async {
    try{
      isLoading(true);
      var response = await ApiGetServices().apiGetServices(AppApiUrl.termAndCondtion);

      if(response != null && response['status'] == 'success' && response['data'] != null){
        termsAndConditionData.value = TermsAndConditonModel.fromJson(response['data']);
      }
    }catch(e){
      
    }
  }
}