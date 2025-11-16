import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Shimmer loading effect for better UX
class LoadingShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

/// Product card shimmer
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingShimmer(
            width: double.infinity,
            height: 120.h,
            borderRadius: 8,
          ),
          SizedBox(height: 8.h),
          LoadingShimmer(
            width: double.infinity,
            height: 16.h,
            borderRadius: 4,
          ),
          SizedBox(height: 4.h),
          LoadingShimmer(
            width: 100.w,
            height: 16.h,
            borderRadius: 4,
          ),
          SizedBox(height: 8.h),
          LoadingShimmer(
            width: 60.w,
            height: 20.h,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// List item shimmer
class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          LoadingShimmer(
            width: 60.w,
            height: 60.h,
            borderRadius: 8,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingShimmer(
                  width: double.infinity,
                  height: 16.h,
                  borderRadius: 4,
                ),
                SizedBox(height: 8.h),
                LoadingShimmer(
                  width: 150.w,
                  height: 14.h,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
