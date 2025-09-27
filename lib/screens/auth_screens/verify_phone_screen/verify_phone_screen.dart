import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parcel_delivery_app/constants/app_colors.dart';
import 'package:parcel_delivery_app/widgets/button_widget/button_widget.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

import '../../../widgets/space_widget/space_widget.dart';
import '../../../widgets/text_button_widget/text_button_widget.dart';
import '../../../widgets/text_field_widget/text_field_widget.dart';
import '../../../widgets/text_widget/text_widgets.dart';
import 'controller/verify_phone_controller.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  VerifyPhoneController? controller;
  late FocusNode _otpFocusNode;
  String phoneNumber = "Loading...";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _otpFocusNode = FocusNode();

    // Defer controller creation to next frame to prevent blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    try {
      if (_isInitialized) return;
      _isInitialized = true;
      // Initialize controller
      controller = Get.put(VerifyPhoneController());
      // Extract phone number safely
      _extractPhoneNumber();
      // Request focus after initialization
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _otpFocusNode.canRequestFocus) {
          _otpFocusNode.requestFocus();
        }
      });
      // Trigger rebuild with updated phone number
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error initializing VerifyPhoneScreen: $e");
      if (mounted) {
        AppSnackBar.error("Failed to load verification screen");
        Get.back();
      }
    }
  }

  void _extractPhoneNumber() {
    try {
      final arguments = Get.arguments;

      if (arguments != null) {
        if (arguments is Map<String, dynamic>) {
          phoneNumber = arguments["phoneNumber"]?.toString() ??
              arguments["mobileNumber"]?.toString() ??
              "Unknown Number";
        } else {
          phoneNumber = arguments.toString();
        }
      } else {
        phoneNumber = "Unknown Number";
      }
    } catch (e) {
      debugPrint("Error extracting phone number: $e");
      phoneNumber = "Unknown Number";
    }
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _handleVerifyOTP() {
    if (controller == null) {
      AppSnackBar.error("Please wait, screen is still loading");
      return;
    }

    // Unfocus and verify
    FocusScope.of(context).unfocus();

    if (controller!.otpController.text.trim().isEmpty) {
      AppSnackBar.error("Please enter the OTP");
      return;
    }

    controller!.verifyOTP();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset:
          false, // Changed to false to handle keyboard manually
      body: SafeArea(
        child: controller == null ? _buildLoadingState() : _buildMainContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.black,
          ),
          SizedBox(height: 16),
          Text(
            "Initializing verification...",
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get keyboard height
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        //final screenHeight = constraints.maxHeight;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: keyboardHeight > 0 ? 80 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SpaceWidget(spaceHeight: 45),
                    TextWidget(
                      text: "verifyPhone".tr,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      fontColor: AppColors.black,
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    TextFieldWidget(
                      controller: controller!.otpController,
                      hintText: '******',
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      focusNode: _otpFocusNode,
                      // onSubmitted: _handleVerifyOTP,
                    ),
                    const SpaceWidget(spaceHeight: 16),
                    TextWidget(
                      text:
                          "${"codeHasSendTo".tr} $phoneNumber. ${"usually".tr}",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontColor: AppColors.greyDarkLight,
                      textAlignment: TextAlign.left,
                    ),
                    const SpaceWidget(spaceHeight: 8),
                    Obx(() => TextButtonWidget(
                          onPressed: controller!.isButtonDisabled.value
                              ? null
                              : () => controller!.resendCode(),
                          text: controller!.isButtonDisabled.value
                              ? "${"sendRepeatSMS".tr} ${controller!.start.value} ${"sec".tr}"
                              : "resendCode".tr,
                          textColor: controller!.isButtonDisabled.value
                              ? AppColors.greyDarkLight
                              : AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ),

            // Fixed button container at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              margin: EdgeInsets.only(bottom: keyboardHeight),
              decoration: const BoxDecoration(
                color: AppColors.white,
              ),
              child: Obx(() {
                final isLoading = controller?.isLoading.value ?? false;
                return isLoading
                    ? Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: LoadingAnimationWidget.progressiveDots(
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      )
                    : ButtonWidget(
                        onPressed: isLoading ? null : _handleVerifyOTP,
                        label: "verify".tr,
                        buttonWidth: double.infinity,
                        buttonHeight: 50,
                      );
              }),
            ),
          ],
        );
      },
    );
  }
}
