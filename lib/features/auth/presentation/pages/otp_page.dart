import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/responsive_utils.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  int _resendTimer = 60;
  Timer? _timer;
  String? _verificationId;
  String? _phoneNumber;
  ConfirmationResult? _confirmationResult; // For web
  bool _isWeb = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Get arguments passed from auth entry page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _verificationId = args['verificationId'] as String?;
          _phoneNumber = args['phoneNumber'] as String?;
          _confirmationResult =
              args['confirmationResult'] as ConfirmationResult?;
          _isWeb = args['isWeb'] as bool? ?? false;
        });
      }
    });
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

  void _resendCode() async {
    if (_phoneNumber == null) return;

    setState(() {
      _resendTimer = 60;
      _pinController.clear();
    });
    _startTimer();

    try {
      if (_isWeb) {
        // Web: Use signInWithPhoneNumber
        _confirmationResult = await _auth.signInWithPhoneNumber(_phoneNumber!);
        if (mounted) {
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
      } else {
        // Mobile: Use verifyPhoneNumber
        await _auth.verifyPhoneNumber(
          phoneNumber: _phoneNumber!,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('حدث خطأ في إرسال الرمز'),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            if (mounted) {
              setState(() {
                _verificationId = verificationId;
              });
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
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _handleVerify() async {
    if (_pinController.text.length == 6) {
      setState(() => _isLoading = true);

      try {
        if (_isWeb && _confirmationResult != null) {
          // Web: Use ConfirmationResult to confirm OTP
          await _confirmationResult!.confirm(_pinController.text);
        } else if (_verificationId != null) {
          // Mobile: Use PhoneAuthCredential with verification ID
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationId!,
            smsCode: _pinController.text,
          );
          await _auth.signInWithCredential(credential);
        } else {
          throw Exception('Missing verification data');
        }

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);

          String errorMessage = 'رمز غير صحيح';

          if (e.code == 'invalid-verification-code') {
            errorMessage = 'رمز غير صحيح';
          } else if (e.code == 'session-expired') {
            errorMessage = 'انتهت صلاحية الرمز. اطلب رمز جديد';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.errorRed,
            ),
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
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
        Gap(24.h),
        Text(
              'تأكيد رقم الهاتف',
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: ResponsiveUtils.fontSize(24),
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.3, end: 0, duration: 400.ms),
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
          _phoneNumber ?? '01xxxxxxxxx',
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
                if (value == null || value.length < 6) {
                  return 'الرجاء إدخال الرمز كاملاً';
                }
                return null;
              },
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms)
        .scale(
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
              )
              .animate()
              .fadeIn(delay: 800.ms)
              .shimmer(
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
        )
        .animate()
        .fadeIn(delay: 1000.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  Widget _buildBackButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.darkGrey),
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
