import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/responsive/responsive_utils.dart';
import '../../domain/todo.dart';
import '../provider/loading_provider.dart';
import '../provider/todos_provider.dart';

/// A dialog for creating a new task or editing an existing one.
class CustomDialogNewTodo extends ConsumerStatefulWidget {
  final Todo? existingTodo; // If provided, edit mode; otherwise, create mode
  final void Function()? onPressedCreate;

  const CustomDialogNewTodo({Key? key, this.existingTodo, this.onPressedCreate}) : super(key: key);

  @override
  ConsumerState<CustomDialogNewTodo> createState() => _CustomDialogNewTodoState();
}

class _CustomDialogNewTodoState extends ConsumerState<CustomDialogNewTodo> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  DateTime? _startTime;
  DateTime? _endTime;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.existingTodo != null) {
      _titleController = TextEditingController(text: widget.existingTodo!.title);
      _descController = TextEditingController(text: widget.existingTodo!.description);
      _startTime = widget.existingTodo!.startAt;
      _endTime = widget.existingTodo!.endAt;
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _startTime = null;
      _endTime = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startTime ?? DateTime.now()) : (_endTime ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? (_startTime ?? DateTime.now()) : (_endTime ?? DateTime.now())),
    );

    if (time == null) return;

    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startTime = combined;
      } else {
        _endTime = combined;
      }
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Not set';
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSave(WidgetRef ref) async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    try {
      if (widget.existingTodo != null) {
        // Edit mode: update the existing todo
        final updated = Todo(
          id: widget.existingTodo!.id,
          title: title,
          description: desc,
          completed: widget.existingTodo!.completed,
          startAt: _startTime,
          endAt: _endTime,
        );
        await ref.read(todosProvider.notifier).editTodo(updated);
      } else {
        // Create mode: add new todo
        await ref
            .read(todosProvider.notifier)
            .addTodo(title: title, description: desc, startAt: _startTime, endAt: _endTime);
      }

      if (widget.onPressedCreate != null) {
        widget.onPressedCreate!();
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingTodo != null;
    final dialogTitle = isEditMode ? 'Edit task' : 'New task';
    final isMobile = ResponsiveUtils.isMobile(context);
    final isLoading = isEditMode ? ref.watch(editLoadingProvider) : ref.watch(createLoadingProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: PopScope(
        canPop: !isLoading,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 24, desktop: 28),
            ),
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
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))
                    : Icon(
                        isEditMode ? Icons.edit_outlined : Icons.note_alt_outlined,
                        color: const Color.fromARGB(255, 143, 128, 128),
                        size: ResponsiveUtils.responsiveSize(context, mobile: 24, tablet: 28, desktop: 32),
                      ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.responsiveSize(context, mobile: 10, tablet: 12, desktop: 14),
                ),
                child: Text(
                  dialogTitle,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 23, tablet: 25, desktop: 28),
                    color: const Color.fromARGB(255, 143, 128, 128),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: ResponsiveUtils.width(context) * (isMobile ? 0.85 : 0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title field
                  TextField(
                    controller: _titleController,
                    enabled: !isLoading,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      color: const Color.fromARGB(255, 128, 124, 124),
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 22, desktop: 24),
                        ),
                      ),
                      filled: false,
                      hintText: 'Task title',
                      hintStyle: TextStyle(
                        fontFamily: 'Lato',
                        color: const Color(0xff9C9A9A),
                        fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16)),
                  // Description field
                  TextField(
                    controller: _descController,
                    enabled: !isLoading,
                    maxLines: 3,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      color: const Color.fromARGB(255, 128, 124, 124),
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 22, desktop: 24),
                        ),
                      ),
                      filled: false,
                      hintText: 'Task description',
                      hintStyle: TextStyle(
                        fontFamily: 'Lato',
                        color: const Color(0xff9C9A9A),
                        fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16)),
                  // Start time picker
                  GestureDetector(
                    onTap: isLoading ? null : () => _pickDateTime(true),
                    child: Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 22, desktop: 24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Start: ${_formatDateTime(_startTime)}',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: isLoading ? Colors.grey : const Color(0xff6C6868),
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                mobile: 13,
                                tablet: 14,
                                desktop: 15,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: ResponsiveUtils.responsiveSize(context, mobile: 18, tablet: 20, desktop: 22),
                            color: isLoading ? Colors.grey : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16)),
                  // End time picker
                  GestureDetector(
                    onTap: isLoading ? null : () => _pickDateTime(false),
                    child: Container(
                      padding: EdgeInsets.all(
                        ResponsiveUtils.responsiveSize(context, mobile: 12, tablet: 14, desktop: 16),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.responsiveSize(context, mobile: 20, tablet: 22, desktop: 24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'End: ${_formatDateTime(_endTime)}',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: isLoading ? Colors.grey : const Color(0xff6C6868),
                              fontSize: ResponsiveUtils.responsiveFontSize(
                                context,
                                mobile: 13,
                                tablet: 14,
                                desktop: 15,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: ResponsiveUtils.responsiveSize(context, mobile: 18, tablet: 20, desktop: 22),
                            color: isLoading ? Colors.grey : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 15, tablet: 15.5, desktop: 16),
                  color: isLoading ? Colors.grey : Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : () async => await _handleSave(ref),
              child: Text(
                isLoading ? 'Loading...' : (isEditMode ? "Save" : "Create"),
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 15, tablet: 15.5, desktop: 16),
                  color: isLoading ? Colors.grey : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
