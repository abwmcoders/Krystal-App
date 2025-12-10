import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/responsive/responsive_utils.dart';
import '../provider/loading_provider.dart';

class CustomDialogDeleteTodo extends ConsumerWidget {
  final String content;
  final void Function()? onPressedDelete;

  const CustomDialogDeleteTodo({super.key, required this.content, required this.onPressedDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(deleteLoadingProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: PopScope(
        canPop: !isLoading,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 24, desktop: 28)),
          ),
          title: Column(
            children: [
              Container(
                height: ResponsiveUtils.responsiveSize(context, mobile: 45, tablet: 50, desktop: 55),
                width: ResponsiveUtils.responsiveSize(context, mobile: 45, tablet: 50, desktop: 55),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 0, offset: Offset(0, 0))],
                  color: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      )
                    : Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.red,
                        size: ResponsiveUtils.responsiveSize(context, mobile: 24, tablet: 28, desktop: 32),
                      ),
              ),
              SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16)),
              Text(
                'Delete Task',
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 143, 128, 128),
                ),
              ),
            ],
          ),
          content: Text(
            content,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
              fontWeight: FontWeight.w500,
              color: const Color(0xff9C9A9A),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 15, tablet: 15.5, desktop: 16),
                  color: isLoading ? Colors.grey : null,
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : () {
                onPressedDelete?.call();
                Navigator.of(context).pop();
              },
              child: Text(
                isLoading ? "Deleting..." : "Delete",
                style: GoogleFonts.montserrat(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 15, tablet: 15.5, desktop: 16),
                  color: isLoading ? Colors.grey : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

