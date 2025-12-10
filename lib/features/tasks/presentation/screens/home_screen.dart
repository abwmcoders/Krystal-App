import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/responsive/responsive_utils.dart';
import '../provider/loading_provider.dart';
import '../provider/tasks_counter_providers.dart';
import '../provider/todos_provider.dart';
import '../widgets/custom_botton_navbar.dart';
import '../widgets/custom_dialog_newtodo.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/todo_widget.dart';
import '../widgets/welcome_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(todosProvider.notifier).loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(filteredTodosProvider);

    final completedCounter = ref.watch(completedCounterProvider);
    final pendingCounter = ref.watch(pendingCounterProvider);
    final remindersCounter = ref.watch(remindersCounterProvider);
    final currentFilter = ref.watch(selectedFilterTodoProvider);

    // Watch for success/error messages
    final successMessage = ref.watch(successMessageProvider);
    final errorMessage = ref.watch(errorMessageProvider);

    // Show SnackBar when success or error message changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
        );
      }
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
        );
      }
    });

    final tasksTitleGroup = switch (currentFilter) {
      TodoFilter.all => 'All tasks',
      TodoFilter.completed => 'Completed tasks',
      TodoFilter.pending => 'Pending tasks',
      TodoFilter.reminders => 'Reminders tasks',
    };

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // WELCOME CARD
            WelcomeCard(
              pendingCounter: pendingCounter,
              completedCounter: completedCounter,
              remindersCounter: remindersCounter,
            ),

            // TODOS TITLE FILTER
            Padding(
              padding: EdgeInsets.fromLTRB(
                ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 30, desktop: 40),
                ResponsiveUtils.responsiveSize(context, mobile: 10, tablet: 12, desktop: 15),
                ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 30, desktop: 40),
                ResponsiveUtils.responsiveSize(context, mobile: 10, tablet: 12, desktop: 15),
              ),
              child: Text(
                tasksTitleGroup,
                style: GoogleFonts.arima(
                  color: const Color(0xff8C8C8C),
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 25, tablet: 28, desktop: 32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //  TODOS LISTVIEW
            Expanded(
              child: todos.isEmpty
                  ? EmptyStateWidget(currentFilter: currentFilter)
                  : MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: todos.length,
                        itemBuilder: (BuildContext context, int index) {
                          final todo = todos[index];
                          return TodoWidget(
                            id: todo.id,
                            title: todo.title,
                            description: todo.description,
                            startAt: todo.startAt,
                            endAt: todo.endAt,
                            completed: todo.completed,
                            onTapCheckBox: () {
                              ref.read(todosProvider.notifier).toggleTodo(todo.id);
                            },
                            onTapDelete: () {
                              ref.read(todosProvider.notifier).deleteTodo(todo.id);
                            },
                            onTapEdit: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return CustomDialogNewTodo(existingTodo: todo);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const CustomDialogNewTodo();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
