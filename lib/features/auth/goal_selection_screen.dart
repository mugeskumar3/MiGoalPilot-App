import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot/app/theme/app_colors.dart';
import 'package:migoalpilot/app/theme/app_text_styles.dart';
import 'package:migoalpilot/core/models/goal_template_registry.dart';
import 'package:migoalpilot/core/widgets/shared_widgets.dart';

class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryTemplates = GoalTemplateRegistry.templates.where(
      (t) => t.id == 'marriage' || t.id == 'emergency_fund' || t.id == 'gold',
    ).toList();

    final secondaryTemplates = GoalTemplateRegistry.templates.where(
      (t) => t.id != 'marriage' && t.id != 'emergency_fund' && t.id != 'gold' && t.id != 'custom',
    ).toList();

    final customTemplate = GoalTemplateRegistry.templates.firstWhere((t) => t.id == 'custom');

    return Scaffold(
      backgroundColor: isLight ? AppColors.background : AppColors.backgroundDark,
      appBar: MiBackAppBar(
        title: 'Choose Your Goal',
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'WHAT ARE YOU PLANNING FOR?',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isLight ? AppColors.textSecondary : AppColors.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a template below to start building your savings flight plan.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 1. Featured Premium Templates (Horizontal list/cards)
              _buildSectionHeader('FEATURED PLANS', isLight),
              const SizedBox(height: 12),
              SizedBox(
                height: 155,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: primaryTemplates.length,
                  itemBuilder: (context, index) {
                    final t = primaryTemplates[index];
                    return _buildFeaturedCard(context, t, isLight);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 2. Standard Templates (Creative Grid)
              _buildSectionHeader('STANDARD TEMPLATES', isLight),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.35,
                ),
                itemCount: secondaryTemplates.length,
                itemBuilder: (context, index) {
                  final t = secondaryTemplates[index];
                  return _buildGridTile(context, t, isLight);
                },
              ),
              const SizedBox(height: 24),

              // 3. Custom Goal Builder (Wide Primary Card)
              _buildSectionHeader('MANUAL BUILDER', isLight),
              const SizedBox(height: 12),
              _buildCustomCard(context, customTemplate, isLight),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isLight) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.bold,
        color: isLight ? AppColors.primary : AppColors.textSecondaryDark,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, GoalTemplate t, bool isLight) {
    // Unique gradients for featured options
    final List<Color> colors;
    if (t.id == 'marriage') {
      colors = isLight
          ? [const Color(0xFFFFECEF), const Color(0xFFFFD1D8)]
          : [const Color(0xFF4A1521), const Color(0xFF2C0A12)];
    } else if (t.id == 'emergency_fund') {
      colors = isLight
          ? [const Color(0xFFECF8FF), const Color(0xFFD0EDFF)]
          : [const Color(0xFF10334A), const Color(0xFF091F2E)];
    } else {
      colors = isLight
          ? [const Color(0xFFFFFBEA), const Color(0xFFFFF1C2)]
          : [const Color(0xFF4C3D0E), const Color(0xFF2E2405)];
    }

    return GestureDetector(
      onTap: () => context.push('/setup-goal/${t.id}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLight
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isLight ? Colors.white : AppColors.surfaceDark).withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Text(t.icon, style: const TextStyle(fontSize: 20)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isLight ? AppColors.textPrimary : AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, GoalTemplate t, bool isLight) {
    return GestureDetector(
      onTap: () => context.push('/setup-goal/${t.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLight ? AppColors.border : AppColors.borderDark,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.icon, style: const TextStyle(fontSize: 22)),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  t.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: isLight ? AppColors.textSecondary : AppColors.textLightDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCard(BuildContext context, GoalTemplate t, bool isLight) {
    return GestureDetector(
      onTap: () => context.push('/setup-goal/${t.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLight
                ? [AppColors.primary, const Color(0xFF1D4D3D)]
                : [AppColors.surfaceDark, AppColors.elevatedSurfaceDark],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLight
                ? Colors.transparent
                : AppColors.borderDark,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(t.icon, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
