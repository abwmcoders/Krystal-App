import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/responsive/responsive_utils.dart';
import '../provider/todos_provider.dart';

class EmptyStateWidget extends StatelessWidget {
  final TodoFilter currentFilter;

  const EmptyStateWidget({super.key, required this.currentFilter});

  String get _emptyMessage {
    return switch (currentFilter) {
      TodoFilter.all => 'No tasks yet',
      TodoFilter.completed => 'No completed tasks',
      TodoFilter.pending => 'All caught up!',
      TodoFilter.reminders => 'No reminders',
    };
  }

  String get _emptySubMessage {
    return switch (currentFilter) {
      TodoFilter.all => 'Create your first task to get started',
      TodoFilter.completed => 'Complete some tasks to see them here',
      TodoFilter.pending => 'No pending tasks right now',
      TodoFilter.reminders => 'Great! No overdue tasks',
    };
  }

  IconData get _emptyIcon {
    return switch (currentFilter) {
      TodoFilter.all => Icons.note_alt_outlined,
      TodoFilter.completed => Icons.check_circle_outline,
      TodoFilter.pending => Icons.calendar_today,
      TodoFilter.reminders => Icons.notifications_none,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Icon
          Container(
            height: ResponsiveUtils.responsiveSize(context, mobile: 80, tablet: 100, desktop: 120),
            width: ResponsiveUtils.responsiveSize(context, mobile: 80, tablet: 100, desktop: 120),
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xffF0F0F0)),
            child: Icon(
              _emptyIcon,
              color: const Color(0xffC0C0C0),
              size: ResponsiveUtils.responsiveSize(context, mobile: 40, tablet: 50, desktop: 60),
            ),
          ),
          SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 24, tablet: 28, desktop: 32)),

          // Empty Title
          Text(
            _emptyMessage,
            style: GoogleFonts.montserrat(
              color: const Color(0xff8C8C8C),
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16)),

          // Empty Subtitle
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.responsiveSize(context, mobile: 30, tablet: 50, desktop: 80),
            ),
            child: Text(
              _emptySubMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: const Color(0xffA0A0A0),
                fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
