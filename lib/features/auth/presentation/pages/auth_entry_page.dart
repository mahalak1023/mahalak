import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../../core/utils/responsive_utils.dart';

class AuthEntryPage extends StatefulWidget {
  const AuthEntryPage({super.key});

  @override
  State<AuthEntryPage> createState() => _AuthEntryPageState();
}

class _AuthEntryPageState extends State<AuthEntryPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (value.length < 10) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushNamed(context, '/otp');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: ResponsiveWrapper(
        applyPadding: false,
        child: SafeArea(
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(),
            tablet: _buildTabletLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: ResponsiveUtils.allPadding(mobile: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap(40.h),
            _buildHeader(),
            Gap(60.h),
            _buildForm(),
            Gap(24.h),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500.w),
        padding: ResponsiveUtils.allPadding(mobile: 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap(60.h),
              _buildHeader(),
              Gap(80.h),
              _buildForm(),
              Gap(32.h),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600.w),
        padding: ResponsiveUtils.allPadding(mobile: 48),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGrey.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap(40.h),
              _buildHeader(),
              Gap(60.h),
              _buildForm(),
              Gap(32.h),
              _buildFooter(),
              Gap(40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App logo/icon
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 40.sp,
            color: AppColors.primaryBlue,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(),
        Gap(24.h),
        Text(
          'مرحباً بك في محلك',
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: ResponsiveUtils.fontSize(28),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(
              begin: 0.3,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
        Gap(12.h),
        Text(
          'سيتم إرسال رمز التحقق إلى رقم هاتفك',
          style: AppTextStyles.secondary.copyWith(
            fontSize: ResponsiveUtils.fontSize(14),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: '05xxxxxxxx',
            keyboardType: TextInputType.phone,
            prefixIcon: Icon(
              Icons.phone_outlined,
              size: 20.sp,
              color: AppColors.accentTeal,
            ),
            validator: _validatePhone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            textInputAction: TextInputAction.done,
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideX(begin: -0.2, end: 0, duration: 400.ms),
          Gap(24.h),
          CustomButton(
            text: 'متابعة',
            onPressed: _handleContinue,
            isLoading: _isLoading,
            icon: Icons.arrow_back_ios,
            height: ResponsiveUtils.height(54),
          )
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.darkGrey.withValues(alpha: 0.2))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'أو',
                style: AppTextStyles.caption,
              ),
            ),
            Expanded(child: Divider(color: AppColors.darkGrey.withValues(alpha: 0.2))),
          ],
        ).animate().fadeIn(delay: 1000.ms),
        Gap(20.h),
        _buildSocialButton(
          icon: Icons.apple,
          text: 'تسجيل الدخول بواسطة Apple',
          onTap: () {
            // TODO: Implement Apple sign in
          },
        ).animate().fadeIn(delay: 1100.ms).slideX(begin: -0.1, end: 0),
        Gap(12.h),
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          text: 'تسجيل الدخول بواسطة Google',
          onTap: () {
            // TODO: Implement Google sign in
          },
        ).animate().fadeIn(delay: 1200.ms).slideX(begin: 0.1, end: 0),
        Gap(32.h),
        Text(
          'بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية',
          style: AppTextStyles.caption.copyWith(
            fontSize: ResponsiveUtils.fontSize(11),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 1300.ms),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.darkGrey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24.sp, color: AppColors.darkGrey),
            Gap(12.w),
            Text(
              text,
              style: AppTextStyles.body.copyWith(
                fontSize: ResponsiveUtils.fontSize(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
