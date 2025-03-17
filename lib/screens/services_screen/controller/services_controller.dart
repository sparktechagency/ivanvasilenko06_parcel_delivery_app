import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/profile_screen/model/profile_model.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/promote_delivery_parcel.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/utils/appLog/app_log.dart';

import '../../../constants/api_url.dart';
import '../../../services/appStroage/share_helper.dart';

class ServiceController extends GetxController {
   RxBool loading = false.obs;
   List<DeliveryPromote> parcelList = <DeliveryPromote>[].obs;

   Future<void> fetchParcelList() async {
     log("1🆗🆗🆗🆗${parcelList.length}🆗🆗🆗🆗");
     var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
     try {
       loading.value = true;
       final response = await ApiGetServices().apiGetServices(AppApiUrl.sevicePromote,token: token);
       log("1🆗🆗🆗🆗${response}🆗🆗🆗🆗");
       if (response["data"] != null && parcelList.isEmpty ) {
         for (var element in response['data']) {
           parcelList.add(DeliveryPromote.fromJson(element));
         }
         log("2🆗🆗🆗🆗${parcelList.length}🆗🆗🆗🆗");


       } else {
         Get.snackbar('Error', 'Failed to load parcels');
       }
     } catch (e) {
       Get.snackbar('Error', e.toString());
     } finally {
       loading.value = false ;
     }
   }
   @override
  void onInit() async{
     fetchParcelList();
    super.onInit();
  }
}