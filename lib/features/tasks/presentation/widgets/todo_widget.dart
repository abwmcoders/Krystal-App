import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/responsive/responsive_utils.dart';
import '../provider/loading_provider.dart';
import 'custom_dialog_deletetodo.dart';
import 'custom_iconbutton.dart';

String _two(int n) => n.toString().padLeft(2, '0');
String _formatDateTime(DateTime dt) {
  final d = dt.toLocal();
  return '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';
}

class TodoWidget extends ConsumerWidget {
  final String id;
  final String title;
  final String description;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool completed;
  final void Function() onTapCheckBox;
  final void Function() onTapDelete;
  final void Function()? onTapEdit;

  const TodoWidget({
    super.key,
    required this.title,
    required this.description,
    required this.id,
    this.startAt,
    this.endAt,
    required this.completed,
    required this.onTapDelete,
    required this.onTapCheckBox,
    this.onTapEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToggling = ref.watch(toggleLoadingProvider) == id;
    final isMobile = ResponsiveUtils.isMobile(context);
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 24, desktop: 28),
        left: ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 30, desktop: 40),
        right: ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 30, desktop: 40),
      ),
      padding: ResponsiveUtils.responsiveCardPadding(context),
      constraints: BoxConstraints(
        minHeight: ResponsiveUtils.responsiveSize(context, mobile: 70, tablet: 80, desktop: 90),
      ),
      decoration: BoxDecoration(
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 0, offset: Offset(0, 0))],
        borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconButton(
            icon: Icon(
              (completed) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: isToggling ? Colors.grey : Colors.blue,
              size: ResponsiveUtils.responsiveSize(context, mobile: 23, tablet: 26, desktop: 28),
            ),
            color: Colors.blue.withValues(alpha: 0.3),
            onTap: isToggling ? () {} : onTapCheckBox,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.responsiveSize(context, mobile: 10, tablet: 14, desktop: 18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: isMobile ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff333333),
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                      fontWeight: FontWeight.bold,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 4, tablet: 6, desktop: 8)),
                  Text(
                    description,
                    // maxLines: isMobile ? 1 : 2,
                    // overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: const Color(0xff6C6868),
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 14.5, desktop: 15),
                      fontWeight: FontWeight.w500,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (startAt != null || endAt != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: ResponsiveUtils.responsiveSize(context, mobile: 6, tablet: 8, desktop: 10),
                      ),
                      child: Text(
                        '${startAt != null ? _formatDateTime(startAt!) : ''}${startAt != null && endAt != null ? '  -  ' : ''}${endAt != null ? _formatDateTime(endAt!) : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: const Color(0xff9C9A9A),
                          fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 12, tablet: 12.5, desktop: 13),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              (completed)
                  ? SizedBox.shrink()
                  : CustomIconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: isToggling ? Colors.grey.shade400 : Colors.grey,
                        size: ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 22, desktop: 24),
                      ),
                      color: Colors.grey.withValues(alpha: 0.12),
                      onTap: isToggling ? () {} : onTapEdit ?? () {},
                    ),
              SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 8, tablet: 10, desktop: 12)),
              CustomIconButton(
                icon: Icon(
                  Icons.disabled_by_default_rounded,
                  color: isToggling ? Colors.red.shade200 : Colors.red,
                  size: ResponsiveUtils.responsiveSize(context, mobile: 23, tablet: 26, desktop: 28),
                ),
                color: Colors.red.withValues(alpha: 0.3),
                onTap: isToggling
                    ? () {}
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialogDeleteTodo(
                              content:
                                  'Are you sure you want to delete this task? Once deleted, it cannot be recovered.',
                              onPressedDelete: onTapDelete,
                            );
                          },
                        );
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
