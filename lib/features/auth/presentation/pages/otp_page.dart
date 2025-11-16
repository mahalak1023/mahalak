import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../../core/utils/responsive_utils.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  void _resendCode() {
    setState(() {
      _resendTimer = 60;
      _pinController.clear();
    });
    _startTimer();
    // TODO: Implement resend OTP API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال الرمز مرة أخرى',
          style: AppTextStyles.body.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _handleVerify() {
    if (_pinController.text.length == 6) {
      setState(() => _isLoading = true);
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.h,
      textStyle: AppTextStyles.body.copyWith(
        fontSize: ResponsiveUtils.fontSize(20),
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.darkGrey.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.accentTeal, width: 2),
      boxShadow: [
        BoxShadow(
          color: AppColors.accentTeal.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primaryBlue, width: 1),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.errorRed, width: 1),
    );

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: const CustomAppBar(title: 'تأكيد الكود'),
      body: ResponsiveWrapper(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: ResponsiveUtils.allPadding(mobile: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(40.h),
                  _buildHeader(),
                  Gap(50.h),
                  _buildPinInput(
                    defaultPinTheme,
                    focusedPinTheme,
                    submittedPinTheme,
                    errorPinTheme,
                  ),
                  Gap(24.h),
                  _buildResendSection(),
                  Gap(40.h),
                  _buildVerifyButton(),
                  Gap(20.h),
                  _buildBackButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 40.sp,
            color: AppColors.accentTeal,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(),
        Gap(24.h),
        Text(
          'تأكيد رقم الهاتف',
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: ResponsiveUtils.fontSize(24),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(
              begin: 0.3,
              end: 0,
              duration: 400.ms,
            ),
        Gap(12.h),
        Text(
          'أدخل رمز التحقق المرسل إلى',
          style: AppTextStyles.secondary.copyWith(
            fontSize: ResponsiveUtils.fontSize(14),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        Gap(4.h),
        Text(
          '05xxxxxxxx',
          style: AppTextStyles.body.copyWith(
            fontSize: ResponsiveUtils.fontSize(16),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildPinInput(
    PinTheme defaultPinTheme,
    PinTheme focusedPinTheme,
    PinTheme submittedPinTheme,
    PinTheme errorPinTheme,
  ) {
    return Center(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          controller: _pinController,
          focusNode: _focusNode,
          length: 6,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          errorPinTheme: errorPinTheme,
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
          showCursor: true,
          cursor: Container(
            width: 2,
            height: 24.h,
            color: AppColors.accentTeal,
          ),
          onCompleted: (pin) => _handleVerify(),
          validator: (value) {
            // Simulate validation - in real app, this would be done server-side
            if (value == null || value.length < 6) {
              return 'الرجاء إدخال الرمز كاملاً';
            }
            return null;
          },
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 400.ms,
        );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        if (_resendTimer > 0)
          Text(
            'إعادة الإرسال بعد $_resendTimer ثانية',
            style: AppTextStyles.secondary.copyWith(
              fontSize: ResponsiveUtils.fontSize(14),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 800.ms)
        else
          TextButton(
            onPressed: _resendCode,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 18.sp,
                  color: AppColors.primaryBlue,
                ),
                Gap(8.w),
                Text(
                  'إعادة إرسال الرمز',
                  style: AppTextStyles.body.copyWith(
                    fontSize: ResponsiveUtils.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms).shimmer(
                duration: 1000.ms,
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
              ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return CustomButton(
      text: 'تحقق',
      onPressed: _handleVerify,
      isLoading: _isLoading,
      icon: Icons.check_circle_outline,
      height: ResponsiveUtils.height(54),
    ).animate().fadeIn(delay: 1000.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: AppColors.darkGrey,
          ),
          Gap(8.w),
          Text(
            'تعديل رقم الهاتف',
            style: AppTextStyles.secondary.copyWith(
              fontSize: ResponsiveUtils.fontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms);
  }
}
