import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../Services/auth_service.dart';

class AuthEntryPage extends StatefulWidget {
  const AuthEntryPage({super.key});

  @override
  State<AuthEntryPage> createState() => _AuthEntryPageState();
}

class _AuthEntryPageState extends State<AuthEntryPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  bool _isLoading = false; // For phone auth
  bool _isGoogleLoading = false; // For Google Sign-In
  String? _verificationId; // Used in phone verification callback
  ConfirmationResult? _confirmationResult; // For web platform

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    // Egyptian phone numbers: 10 or 11 digits (01xxxxxxxxx)
    if (value.length < 10 || value.length > 11) {
      return 'رقم الهاتف غير صحيح';
    }
    // Must start with 01
    if (!value.startsWith('01')) {
      return 'يجب أن يبدأ رقم الهاتف بـ 01';
    }
    return null;
  }

  void _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Format Egyptian phone number to E.164 format (+20xxxxxxxxxx)
        String phoneNumber = _phoneController.text.trim();
        // Remove leading 0 if exists and add +20
        if (phoneNumber.startsWith('0')) {
          phoneNumber = phoneNumber.substring(1);
        }
        phoneNumber = '+20$phoneNumber';

        if (kIsWeb) {
          // Web platform: Use signInWithPhoneNumber with reCAPTCHA
          _confirmationResult = await _auth.signInWithPhoneNumber(
            phoneNumber,
            // RecaptchaVerifier is automatically handled by Firebase on web
          );

          if (mounted) {
            setState(() => _isLoading = false);
            // Navigate to OTP page with confirmation result
            Navigator.pushNamed(
              context,
              '/otp',
              arguments: {
                'confirmationResult': _confirmationResult,
                'phoneNumber': phoneNumber,
                'isWeb': true,
              },
            );
          }
        } else {
          // Mobile platforms: Use verifyPhoneNumber
          await _auth.verifyPhoneNumber(
            phoneNumber: phoneNumber,
            verificationCompleted: (PhoneAuthCredential credential) async {
              // Auto-verification (Android only)
              await _auth.signInWithCredential(credential);
              if (mounted) {
                setState(() => _isLoading = false);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              }
            },
            verificationFailed: (FirebaseAuthException e) {
              if (mounted) {
                setState(() => _isLoading = false);
                String errorMessage = 'حدث خطأ في إرسال الرمز';

                if (e.code == 'invalid-phone-number') {
                  errorMessage = 'رقم الهاتف غير صحيح';
                } else if (e.code == 'too-many-requests') {
                  errorMessage = 'تم تجاوز عدد المحاولات. حاول لاحقاً';
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
              }
            },
            codeSent: (String verificationId, int? resendToken) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });

                // Navigate to OTP page with verification ID and phone number
                Navigator.pushNamed(
                  context,
                  '/otp',
                  arguments: {
                    'verificationId': verificationId,
                    'phoneNumber': phoneNumber,
                    'isWeb': false,
                  },
                );
              }
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              _verificationId = verificationId;
            },
            timeout: const Duration(seconds: 60),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        // Success: Navigate to home
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        }
      } else {
        // User canceled or double-tap ignored
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إلغاء تسجيل الدخول بواسطة جوجل.'),
              backgroundColor: AppColors.darkGrey,
            ),
          );
        }
      }
    } catch (e) {
      // Handle exceptions from the service
      debugPrint('Google Sign-In Error: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل تسجيل الدخول. برجاء المحاولة مرة أخرى.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _handleAppleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithApple();

      if (userCredential != null && mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        // User canceled sign-in
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ في تسجيل الدخول بواسطة Apple: ${e.toString()}',
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  // Show dialog to sign up / sign in with email & password
  void _showEmailAuthDialog() {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    final _confirmController = TextEditingController();
    final _formKeyEmail = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        bool _loading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('التسجيل بواسطة البريد الإلكتروني'),
              content: Form(
                key: _formKeyEmail,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'الرجاء إدخال البريد الإلكتروني';
                        if (!v.contains('@'))
                          return 'البريد الإلكتروني غير صالح';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'الرجاء إدخال كلمة المرور';
                        if (v.length < 6)
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                      ),
                      validator: (v) {
                        if (v != _passwordController.text)
                          return 'كلمتا المرور غير متطابقتين';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (!_formKeyEmail.currentState!.validate()) return;
                          setState(() => _loading = true);
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          final result = await _authService.createUserWithEmail(
                            email: email,
                            password: password,
                          );
                          setState(() => _loading = false);
                          if (result != null && mounted) {
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء التسجيل'),
                              ),
                            );
                          }
                        },
                  child: const Text('سجل'),
                ),
              ],
            );
          },
        );
      },
    );
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
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
        Gap(24.h),
        Text(
              'مرحباً بك في محلك',
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: ResponsiveUtils.fontSize(28),
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(
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
                hint: '01xxxxxxxxx',
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  size: 20.sp,
                  color: AppColors.accentTeal,
                ),
                validator: _validatePhone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
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
            Expanded(
              child: Divider(color: AppColors.darkGrey.withValues(alpha: 0.2)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text('أو', style: AppTextStyles.caption),
            ),
            Expanded(
              child: Divider(color: AppColors.darkGrey.withValues(alpha: 0.2)),
            ),
          ],
        ).animate().fadeIn(delay: 1000.ms),
        Gap(20.h),
        // Email/password signup button
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: InkWell(
            onTap: _showEmailAuthDialog,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                  const Icon(Icons.email, size: 24, color: Colors.black54),
                  Gap(12.w),
                  Text(
                    'التسجيل بواسطة البريد الإلكتروني',
                    style: AppTextStyles.body.copyWith(
                      fontSize: ResponsiveUtils.fontSize(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 1000.ms),

        _buildSocialButton(
          icon: Icons.apple,
          text: 'تسجيل الدخول بواسطة Apple',
          onTap: _handleAppleSignIn,
        ).animate().fadeIn(delay: 1100.ms).slideX(begin: -0.1, end: 0),
        Gap(12.h),
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          text: 'تسجيل الدخول بواسطة Google',
          onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
          isLoading: _isGoogleLoading,
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
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
          children: isLoading
              ? [
                  SizedBox(
                    width: 24.sp,
                    height: 24.sp,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ]
              : [
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
