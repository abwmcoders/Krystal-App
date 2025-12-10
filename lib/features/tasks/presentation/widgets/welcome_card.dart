import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../config/responsive/responsive_utils.dart';
import '../provider/todos_provider.dart';
import 'custom_searchbar.dart';

class WelcomeCard extends ConsumerStatefulWidget {
  final int completedCounter;
  final int pendingCounter;
  final int remindersCounter;

  const WelcomeCard({
    super.key,
    required this.completedCounter,
    required this.pendingCounter,
    required this.remindersCounter,
  });

  @override
  ConsumerState<WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends ConsumerState<WelcomeCard> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Keep search provider in sync with controller (real-time search)
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveUtils.getWelcomeCardHeight(context),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUtils.responsiveSize(context, mobile: 22, tablet: 28, desktop: 32)),
          bottomRight: Radius.circular(ResponsiveUtils.responsiveSize(context, mobile: 22, tablet: 28, desktop: 32)),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(1, 0),
          colors: [Color(0xffF4C465), Color(0xffC63956)],
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Image.asset('assets/images/img_saly10.png'),
          // Lottie.asset('assets/images/todo.lottie'),
          SizedBox(
  width: 200,  // Adjust as needed
  height: 200,
  child: Lottie.asset(
    'assets/images/todo.json',
    repeat: true,  // Loop the animation (default is true)
    reverse: false,  // Play in reverse (default is false)
    animate: true,  // Start animation automatically (default is true)
  ),
),
          Positioned(
            left: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveUtils.responsiveSize(context, mobile: 50, tablet: 40, desktop: 30),
                left: ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 30, desktop: 40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, Welcome 👋',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 28, tablet: 32, desktop: 36),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your day looks like this:',
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 10, tablet: 12, desktop: 14)),
                  TasksCounterCard(
                    tasksCounter: widget.pendingCounter,
                    typeTask: 'pending',
                    iconData: Icons.calendar_month_rounded,
                  ),
                  TasksCounterCard(
                    tasksCounter: widget.completedCounter,
                    typeTask: 'completed',
                    iconData: Icons.check_circle,
                  ),
                  TasksCounterCard(
                    tasksCounter: widget.remindersCounter,
                    typeTask: 'reminders',
                    iconData: Icons.check_circle,
                  ),
                ],
              ),
            ),
          ),

          // SEARCHBAR
          Positioned(
            right: 0,
            top: 0,
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 24, desktop: 28)),
              child: AnimSearchBar(
                autoFocus: false,
                width: ResponsiveUtils.width(context) * 0.9,
                textController: _searchController,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: const Color(0xff9C9A9A),
                  size: ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
                suffixIcon: Icon(
                  Icons.clear_rounded,
                  color: const Color(0xff9C9A9A),
                  size: ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
                textFieldIconColor: const Color(0xff9C9A9A),
                style: GoogleFonts.montserrat(
                  color: const Color(0xff9C9A9A),
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                ),
                cursorColor: const Color(0xff9C9A9A),
                onSuffixTap: () {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                },
                onSubmitted: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TasksCounterCard extends StatelessWidget {
  final int tasksCounter;
  final String typeTask;
  final IconData iconData;

  const TasksCounterCard({super.key, required this.tasksCounter, required this.typeTask, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.responsiveSize(context, mobile: 8, tablet: 10, desktop: 12)),
      child: Container(
        constraints: BoxConstraints(
          minHeight: ResponsiveUtils.responsiveSize(context, mobile: 28, tablet: 32, desktop: 36),
          minWidth: ResponsiveUtils.responsiveSize(context, mobile: 152, tablet: 170, desktop: 190),
        ),
        decoration: BoxDecoration(
          color: const Color(0xff00F0FF),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.responsiveSize(context, mobile: 30, tablet: 32, desktop: 35),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16),
            ResponsiveUtils.responsiveSize(context, mobile: 5, tablet: 6, desktop: 8),
            ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16),
            ResponsiveUtils.responsiveSize(context, mobile: 7, tablet: 8, desktop: 10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                iconData,
                color: Colors.white,
                size: ResponsiveUtils.responsiveSize(context, mobile: 16, tablet: 18, desktop: 20),
              ),
              SizedBox(width: ResponsiveUtils.responsiveSize(context, mobile: 5, tablet: 7, desktop: 8)),
              Flexible(
                child: Text(
                  '$tasksCounter tasks $typeTask',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xff8C8C8C).withValues(alpha: 0.8),
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 12, tablet: 12.5, desktop: 13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
