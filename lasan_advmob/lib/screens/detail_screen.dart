import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lasan_advmob/widgets/custom_text.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String body;

  const DetailScreen({super.key, required this.title, required this.body});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: CustomText(
          text: 'Detail Screen',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Placeholder(fallbackHeight: 200.h),
            SizedBox(height: 10.h),
            CustomText(
              text: widget.title,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 20.h),
            CustomText(text: widget.body, fontSize: 16.sp),
          ],
        ),
      ),
    );
  }
}
