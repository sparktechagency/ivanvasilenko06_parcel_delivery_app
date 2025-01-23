import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/text_button_widget/text_button_widget.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_image_path.dart';
import '../../constants/app_strings.dart';
import '../../widgets/image_widget/image_widget.dart';
import '../../widgets/space_widget/space_widget.dart';
import '../../widgets/text_widget/text_widgets.dart';
import '../home_screen/widgets/suggestionCardWidget.dart';

class ServicesScreen extends StatelessWidget {
  final List<String> images = [
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
    AppImagePath.sendParcel,
  ];

  final List<String> title = [
    'Parcel 1',
    'Parcel 2',
    'Parcel 3',
  ];
  final List<String> address = [
    'Western Wall',
    'Western Wall',
    'Western Wall',
  ];

  ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceWidget(spaceHeight: 48),
            const TextWidget(
              text: AppStrings.services,
              fontSize: 30,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SpaceWidget(spaceHeight: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SuggestionCardWidget(
                          onTap: () {},
                          text: AppStrings.deliverParcel,
                          imagePath: AppImagePath.deliverParcel,
                        ),
                        SuggestionCardWidget(
                          onTap: () {},
                          text: AppStrings.sendParcel,
                          imagePath: AppImagePath.sendParcel,
                        ),
                        SuggestionCardWidget(
                          onTap: () {},
                          text: AppStrings.reserve,
                          imagePath: AppImagePath.reserve,
                        ),
                      ],
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextWidget(
                          text: AppStrings.recentPublishedOrders,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontColor: AppColors.black,
                          fontStyle: FontStyle.italic,
                        ),
                        TextButtonWidget(
                          onPressed: () {},
                          text: AppStrings.viewAll,
                          textColor: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    const SpaceWidget(spaceHeight: 14),
                    ...List.generate(images.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ImageWidget(
                                  height: 51,
                                  width: 77,
                                  imagePath: images[index],
                                ),
                                const SpaceWidget(spaceWidth: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: title[index],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.black,
                                    ),
                                    const SpaceWidget(spaceHeight: 4),
                                    TextWidget(
                                      text: address[index],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontColor: AppColors.black,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const TextWidget(
                                  text: "${AppStrings.currency} 150",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontColor: AppColors.black,
                                ),
                                TextButtonWidget(
                                  onPressed: () {},
                                  text: AppStrings.seeDetails,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  textColor: AppColors.black,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SpaceWidget(spaceHeight: 14),
                    const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: ImageWidget(
                        height: 180,
                        width: double.infinity,
                        imagePath: AppImagePath.servicesImage,
                      ),
                    ),
                    const SpaceWidget(spaceHeight: 14),
                    ButtonWidget(
                      onPressed: () {},
                      label: AppStrings.earnMoneyInYourRadius,
                      buttonWidth: double.infinity,
                      buttonHeight: 50,
                      icon: Icons.currency_exchange_rounded,
                      iconColor: AppColors.white,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
