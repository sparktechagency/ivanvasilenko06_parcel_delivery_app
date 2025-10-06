import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/icon_widget/icon_widget.dart';
import '../../../widgets/image_widget/image_widget.dart';
import '../../../widgets/space_widget/space_widget.dart';
import 'dart:developer';

class HomeScreenAppBar extends StatelessWidget {
  final String logoImagePath;
  final String notificationIconPath;
  final VoidCallback onNotificationPressed;
  final String badgeLabel;
  final String profileImagePath;
  final bool isLabelVisible;

  const HomeScreenAppBar({
    super.key,
    required this.logoImagePath,
    required this.notificationIconPath,
    required this.onNotificationPressed,
    required this.badgeLabel,
    required this.profileImagePath,
    required this.isLabelVisible,
  });

  @override
  Widget build(BuildContext context) {
    //! log('🖼️ HomeScreenAppBar building with profileImagePath: $profileImagePath');

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 60, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ImageWidget(
            height: 48,
            width: 170,
            imagePath: logoImagePath,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: "Notifications",
                onPressed: onNotificationPressed,
                icon: Badge(
                  isLabelVisible: isLabelVisible,
                  label: Text(badgeLabel),
                  backgroundColor: AppColors.red,
                  child: IconWidget(
                    icon: notificationIconPath,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              const SpaceWidget(spaceWidth: 12),
              _buildProfileImage(),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    log('🔍 Building profile image with path: $profileImagePath');

    // Check if the profileImagePath is the transparent placeholder
    if (profileImagePath.startsWith('data:image/png;base64,')) {
      log('📷 Using transparent placeholder');
      return _buildFallbackImage();
    }

    // For network images
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: CachedNetworkImage(
        imageUrl: profileImagePath,
        height: 40,
        width: 40,
        fit: BoxFit.cover,
        httpHeaders: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        placeholder: (context, url) {
          //! log('⏳ Loading image: $url');
          return Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.black,
              size: 40,
            ),
          );
        },
        errorWidget: (context, url, error) {
          //! log('🚨 CachedNetworkImage Error for URL: $url');
          //!  log('🚨 Error details: $error');
          //!  log('🚨 Error type: ${error.runtimeType}');

          // Try to determine the type of error
          String errorMessage = 'Network error';
          if (error.toString().contains('404')) {
            errorMessage = 'Image not found (404)';
          } else if (error.toString().contains('timeout')) {
            errorMessage = 'Request timeout';
          } else if (error.toString().contains('ssl') ||
              error.toString().contains('certificate')) {
            errorMessage = 'SSL/Certificate error';
          }

          log('🚨 Error category: $errorMessage');
          return _buildFallbackImage();
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutCurve: Curves.easeInOut,
        fadeOutDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[400]!, width: 1),
        ),
        child: Image.network(
          'https://i.ibb.co/z5YHLV9/profile.png',
          height: 40,
          width: 40,
          fit: BoxFit.cover,
        ));
  }
}
