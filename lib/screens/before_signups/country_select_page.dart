import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/auth_screens/signup_screen/controller/signup_controller.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/space_widget/space_widget.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class CountrySelectPage extends StatefulWidget {
  const CountrySelectPage({super.key});

  @override
  _CountrySelectPageState createState() => _CountrySelectPageState();
}

class _CountrySelectPageState extends State<CountrySelectPage> {
  final SignUpScreenController controller = Get.put(SignUpScreenController());
  String _countryFlag = "🇮🇱";

  @override
  void initState() {
    super.initState();
    // Initialize with Israel
    controller.countryController.text = "Israel";
  }

  void _pickCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          controller.countryController.text = country.name;
          _countryFlag = country.flagEmoji;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceWidget(spaceHeight: 48),
              TextWidget(
                text: "getStarted".tr,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontColor: AppColors.black,
              ),
              const SpaceWidget(spaceHeight: 10),
              TextWidget(
                text: "countryDesciption".tr,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontColor: AppColors.black,
                textAlignment: TextAlign.left,
              ),
              const SpaceWidget(spaceHeight: 24),
              TextFormField(
                controller: controller.countryController,
                readOnly: true,
                decoration: InputDecoration(
                  focusColor: AppColors.greyDarkLight2,
                  hoverColor: AppColors.greyDarkLight2,
                  labelText: 'Country',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _countryFlag,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  border: const OutlineInputBorder(),
                ),
                onTap: () => _pickCountry(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              borderRadius: BorderRadius.circular(100),
              child: CircleAvatar(
                backgroundColor: AppColors.grey,
                radius: ResponsiveUtils.width(25),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.black,
                ),
              ),
            ),
            ButtonWidget(
              onPressed: () {
                Get.toNamed(AppRoutes.languageSelectScreen);
              },
              label: "next".tr,
              icon: Icons.arrow_forward,
              buttonWidth: 120,
              buttonHeight: 50,
            ),
          ],
        ),
      ),
    );
  }
}
