import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/utils/app_size.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';

class DeliveryTypeScreen extends StatefulWidget {
  const DeliveryTypeScreen({super.key});

  @override
  State<DeliveryTypeScreen> createState() => _DeliveryTypeScreenState();
}

class _DeliveryTypeScreenState extends State<DeliveryTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SpaceWidget(spaceHeight: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextWidget(
              text: AppStrings.deliveryType,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontColor: AppColors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SpaceWidget(spaceHeight: 24),
          CarouselSlider(
            options: CarouselOptions(
              height: ResponsiveUtils.height(200),
            ),
            items: [1, 2, 3, 4, 5].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Column(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(color: Colors.amber),
                          child: Text(
                            'text $i',
                            style: TextStyle(fontSize: 16.0),
                          )),
                    ],
                  );
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
