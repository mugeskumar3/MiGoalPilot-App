import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migoalpilot_app/app/theme/app_colors.dart';
import 'package:migoalpilot_app/app/theme/app_text_styles.dart';
import 'package:migoalpilot_app/core/widgets/shared_widgets.dart';
import 'package:migoalpilot_app/core/viewmodels/viewmodels.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  String _selectedCurrency = 'INR';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).user;
    final profileState = ref.read(profileViewModelProvider);

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _countryController = TextEditingController(text: user?.country ?? 'India');
    _selectedCurrency = profileState.currency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    final user = ref.read(authViewModelProvider).user;
    final profileState = ref.read(profileViewModelProvider);

    return _nameController.text != (user?.name ?? '') ||
        _emailController.text != (user?.email ?? '') ||
        _phoneController.text != (user?.phone ?? '') ||
        _countryController.text != (user?.country ?? '') ||
        _selectedCurrency != profileState.currency;
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges()) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.surface
            : AppColors.surfaceDark,
        title: const Text(
          'Discard changes?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Your changes haven\'t been saved yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref
        .read(authViewModelProvider.notifier)
        .updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          country: _countryController.text.trim(),
        );

    if (success) {
      ref
          .read(profileViewModelProvider.notifier)
          .setCurrency(_selectedCurrency);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              ref.read(authViewModelProvider).error ??
              'Could not update your profile. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final user = ref.watch(authViewModelProvider).user;

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isLight
            ? AppColors.background
            : AppColors.backgroundDark,
        appBar: MiBackAppBar(
          title: 'Edit Profile',
          onBackPressed: () async {
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              context.pop();
            }
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: isLight
                                ? AppColors.surface
                                : AppColors.surfaceDark,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (ctx) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_camera),
                                    title: const Text('Take Photo'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Camera picker is not supported in Mock mode.',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose from Gallery'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gallery picker is not supported in Mock mode.',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    title: const Text(
                                      'Remove Photo',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Photo removed'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: isLight
                                    ? AppColors.surface
                                    : AppColors.surfaceDark,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isLight
                                      ? AppColors.border
                                      : AppColors.borderDark,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  (user?.name.isNotEmpty == true)
                                      ? user!.name[0].toUpperCase()
                                      : 'M',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: isLight
                                        ? AppColors.primary
                                        : AppColors.accentDark,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isLight
                                      ? AppColors.primary
                                      : AppColors.accentDark,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: isLight
                                      ? Colors.white
                                      : AppColors.backgroundDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Change profile avatar photo',
                        style: AppTextStyles.caption.copyWith(
                          color: isLight
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                Text(
                  'FULL NAME',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    if (value.trim().length < 3) return 'Name is too short';
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'EMAIL ADDRESS',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  enabled: false, // Email is treated as immutable read-only
                  decoration: const InputDecoration(
                    hintText: 'Enter your email address',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your login email is managed securely and cannot be changed.',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: isLight
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'PHONE NUMBER',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'e.g. +91 98765 43210',
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'COUNTRY',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _countryController,
                  readOnly: true,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: isLight
                          ? AppColors.surface
                          : AppColors.surfaceDark,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'SELECT COUNTRY',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView(
                                children:
                                    [
                                      'India',
                                      'United States',
                                      'Singapore',
                                      'United Kingdom',
                                      'Australia',
                                      'Germany',
                                    ].map((country) {
                                      return ListTile(
                                        title: Text(
                                          country,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onTap: () {
                                          _countryController.text = country;
                                          Navigator.pop(ctx);
                                        },
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'PREFERRED CURRENCY',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isLight ? AppColors.surface : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isLight ? AppColors.border : AppColors.borderDark,
                      width: 1.2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      dropdownColor: isLight
                          ? AppColors.surface
                          : AppColors.surfaceDark,
                      items: const [
                        DropdownMenuItem(
                          value: 'INR',
                          child: Text(
                            '₹ INR (Indian Rupee)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text(
                            '\$ USD (US Dollar)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'SGD',
                          child: Text(
                            'S\$ SGD (Singapore Dollar)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'GBP',
                          child: Text(
                            '£ GBP (British Pound)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCurrency = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                PrimaryButton(
                  text: _isLoading ? 'Saving...' : 'Save Changes',
                  onPressed: _isLoading ? null : _saveProfile,
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
