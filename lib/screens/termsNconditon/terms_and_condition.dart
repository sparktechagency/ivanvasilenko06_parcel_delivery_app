import 'package:flutter/material.dart';
import 'package:parcel_delivery_app/widgets/text_widget/text_widgets.dart';

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [
            TextWidget(text: "Terms And Condition"),
          ],
        ),
      )),
    );
  }
}