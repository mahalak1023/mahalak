import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/responsive_utils.dart';

class AuthEntryPage extends StatefulWidget {
  const AuthEntryPage({super.key});

  @override
  State<AuthEntryPage> createState() => _AuthEntryPageState();
}

class _AuthEntryPageState extends State<AuthEntryPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!value.contains('@')) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'حدث خطأ ما')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'حدث خطأ ما')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: context.isDesktop ? 500.w : double.infinity,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: context.isDesktop ? 0 : 24.w,
              ),
              padding: EdgeInsets.all(context.isDesktop ? 48.r : 24.r),
              decoration: context.isDesktop
                  ? BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkGrey.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(context.isDesktop ? 20.h : 40.h),
                  _buildHeader(),
                  Gap(60.h),
                  _buildForm(),
                  Gap(24.h),
                  _buildFooter(),
                  Gap(context.isDesktop ? 20.h : 0),
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
          'سجل الدخول أو أنشئ حسابًا جديدًا',
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
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(
              Icons.email_outlined,
              size: 20.sp,
              color: AppColors.accentTeal,
            ),
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
          )
              .animate()
              .fadeIn(delay: 600.ms)
              .slideX(begin: -0.2, end: 0, duration: 400.ms),
          Gap(16.h),
          CustomTextField(
            controller: _passwordController,
            label: 'كلمة المرور',
            hint: '********',
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            prefixIcon: Icon(
              Icons.lock_outlined,
              size: 20.sp,
              color: AppColors.accentTeal,
            ),
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
          )
              .animate()
              .fadeIn(delay: 700.ms)
              .slideX(begin: -0.2, end: 0, duration: 400.ms),
          Gap(12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: Text(
                'هل نسيت كلمة المرور؟',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: ResponsiveUtils.fontSize(12),
                ),
              ),
            ),
          ),
          Gap(12.h),
          CustomButton(
            text: 'تسجيل الدخول',
            onPressed: _handleLogin,
            isLoading: _isLoading,
            height: ResponsiveUtils.height(54),
          )
              .animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          Gap(12.h),
          CustomButton(
            text: 'إنشاء حساب جديد',
            onPressed: _handleSignUp,
            isLoading: _isLoading,
            isOutlined: true,
            height: ResponsiveUtils.height(54),
          )
              .animate()
              .fadeIn(delay: 900.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
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
}
