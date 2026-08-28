import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';
import 'package:migoalpilot/core/viewmodels/viewmodels.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final userName = user?.name ?? 'Mugesh R';
    final userEmail = user?.email ?? 'mugesh@example.com';
    final userPhone = user?.phone;
    final userCountry = user?.country;

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Personal Information',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent,
                          Color(0xFFB8963A),
                          AppColors.accent,
                        ],
                      ),
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : AppColors.surfaceDark,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLight ? AppColors.primary : AppColors.backgroundDark,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'M',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: isLight ? AppColors.primary : AppColors.accentDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Profile info details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isLight ? AppColors.surface : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isLight ? AppColors.border : AppColors.borderDark,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.person_outline_rounded,
                    'Full Name',
                    userName,
                    isLight,
                  ),
                  _buildDetailDivider(isLight),
                  _buildDetailRow(
                    Icons.email_outlined,
                    'Email Address',
                    userEmail,
                    isLight,
                  ),
                  _buildDetailDivider(isLight),
                  _buildDetailRow(
                    Icons.phone_outlined,
                    'Phone Number',
                    (userPhone == null || userPhone.isEmpty) ? 'Not set' : userPhone,
                    isLight,
                    isEmpty: userPhone == null || userPhone.isEmpty,
                  ),
                  _buildDetailDivider(isLight),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Country',
                    (userCountry == null || userCountry.isEmpty) ? 'Not set' : userCountry,
                    isLight,
                    isEmpty: userCountry == null || userCountry.isEmpty,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Edit Profile Button
            PrimaryButton(
              text: 'Edit Profile',
              onPressed: () => context.push('/edit-profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isLight, {
    bool isEmpty = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isLight ? AppColors.primary.withValues(alpha: 0.6) : AppColors.accentDark.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isLight ? AppColors.textLight : AppColors.textLightDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: isEmpty
                      ? (isLight ? AppColors.textLight : AppColors.textLightDark)
                      : (isLight ? AppColors.textPrimary : AppColors.textPrimaryDark),
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailDivider(bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Divider(
        height: 1,
        thickness: 0.4,
        color: isLight ? AppColors.border : AppColors.borderDark,
      ),
    );
  }
}
