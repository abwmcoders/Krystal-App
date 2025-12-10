# Testing Guide: Loading States & Feedback

## What to Test

### 1. Create Task Loading State
**Steps:**
1. Tap the FAB (+ button) to open create dialog
2. Enter a task title (required)
3. Optionally add description and dates
4. Tap "Create" button

**Expected Behavior:**
- ✓ Icon becomes a blue spinning circle
- ✓ Button text changes to "Loading..."
- ✓ Input fields turn grey (disabled)
- ✓ Dialog cannot be dismissed (back button won't work)
- ✓ Wait 3 seconds (simulated API call)
- ✓ Dialog closes automatically
- ✓ Green SnackBar appears: "Task created successfully!"
- ✓ New task appears in the list
- ✓ SnackBar disappears after 2 seconds
- ✓ Task counters update (pending count increases)

### 2. Edit Task Loading State
**Steps:**
1. Find an incomplete task in the list
2. Tap the edit (pencil) icon
3. Modify the task title/description/dates
4. Tap "Save" button

**Expected Behavior:**
- ✓ Icon becomes a blue spinning circle
- ✓ Button text changes to "Loading..."
- ✓ Input fields turn grey (disabled)
- ✓ Wait 3 seconds
- ✓ Dialog closes
- ✓ Green SnackBar: "Task updated successfully!"
- ✓ Task list updates with new values
- ✓ SnackBar disappears after 2 seconds

### 3. Delete Task Loading State
**Steps:**
1. Find any task in the list
2. Tap the delete (X) button
3. Confirmation dialog appears
4. Tap "Delete" button

**Expected Behavior:**
- ✓ Icon becomes a red spinning circle
- ✓ Button text changes to "Deleting..."
- ✓ Cancel and Delete buttons turn grey
- ✓ Dialog cannot be dismissed (back button won't work)
- ✓ Wait 3 seconds
- ✓ Dialog closes automatically
- ✓ Green SnackBar: "Task deleted successfully!"
- ✓ Task disappears from list
- ✓ Task counters update (counts decrease)
- ✓ SnackBar disappears after 2 seconds
- ✓ If all tasks deleted, empty state appears

### 4. Toggle Task (Checkbox) Loading State
**Steps:**
1. Find an incomplete task
2. Tap the checkbox on the left side

**Expected Behavior:**
- ✓ Checkbox icon turns grey
- ✓ Edit button becomes lighter/disabled
- ✓ Delete button becomes lighter/disabled
- ✓ Cannot click other buttons on this task
- ✓ Wait 3 seconds
- ✓ Colors return to normal
- ✓ Task now shows completed state (strikethrough on text)
- ✓ Task moves to "completed" filter if filtered by pending
- ✓ Completed counter increases, pending decreases
- ✓ No success message (just visual feedback)

### 5. Toggle Back to Incomplete
**Steps:**
1. Find a completed task (with strikethrough)
2. Tap the checkbox

**Expected Behavior:**
- ✓ Same loading state as above
- ✓ Wait 3 seconds
- ✓ Task becomes incomplete again
- ✓ Strikethrough removed
- ✓ Edit button reappears
- ✓ Counters reverse (completed decreases, pending increases)

### 6. Error Handling
**Steps:**
1. Create a new task
2. During loading, force close the app (simulate network error)
3. Reopen the app

**Expected Behavior:**
- ✓ If error occurs, error message shown in red SnackBar
- ✓ Error message displays specific error details
- ✓ Loading state ends
- ✓ Dialog closes
- ✓ User can try again
- ✓ SnackBar disappears after 3 seconds

### 7. Cancel During Loading
**Steps:**
1. Tap FAB to create task
2. Enter task title
3. Tap "Create"
4. Immediately tap phone back button (before 3 seconds)

**Expected Behavior:**
- ✓ Dialog stays open (cannot dismiss during loading)
- ✓ Back button has no effect
- ✓ Must wait for operation to complete
- ✓ Once complete, dialog closes normally

### 8. Multiple Quick Clicks
**Steps:**
1. Create a task and while loading, click buttons multiple times
2. Or toggle a task checkbox multiple times quickly

**Expected Behavior:**
- ✓ Disabled buttons prevent multiple clicks
- ✓ Only one operation executes
- ✓ No duplicate entries created
- ✓ No duplicate deletions

### 9. Edit Completed Task
**Steps:**
1. Find a completed task (strikethrough text)
2. Notice the edit button is NOT visible

**Expected Behavior:**
- ✓ Edit button hidden for completed tasks
- ✓ Only delete button visible
- ✓ Can still toggle back to incomplete
- ✓ Once incomplete, edit button reappears

### 10. Empty State After Delete All
**Steps:**
1. Delete all tasks one by one

**Expected Behavior:**
- ✓ After deleting last task, empty state appears
- ✓ Shows "No tasks yet" message with icon
- ✓ Appropriate message for current filter
- ✓ FAB still visible and functional
- ✓ Can create new task from empty state

## Performance Checklist

- ✓ Loading spinner spins smoothly (no jank)
- ✓ UI remains responsive during simulated API delay
- ✓ Dialog transitions are smooth
- ✓ SnackBar animations are smooth
- ✓ No console errors or warnings
- ✓ Memory usage is reasonable
- ✓ No lag when typing in input fields
- ✓ Date/time picker responsive when enabled

## Visual Polish Checklist

- ✓ Loading spinners are visible and appropriately colored
  - Blue for create/edit
  - Red for delete
- ✓ Button text updates clearly show loading state
- ✓ Disabled buttons are noticeably greyed out
- ✓ Input fields show disabled state (light grey)
- ✓ Success message is green and clear
- ✓ Error message is red and clear
- ✓ SnackBar position doesn't overlap important UI
- ✓ Spinner rotation is smooth and continuous

## Test Scenarios by Filter

Test each operation with different filters active:

### All Tasks Filter
- ✓ Create new task → appears in list immediately
- ✓ Delete task → removed from list
- ✓ Toggle task → stays in list, text updates
- ✓ Empty state shows: "No tasks yet"

### Pending Tasks Filter
- ✓ Create task → appears (not completed)
- ✓ Delete task → removed
- ✓ Toggle to complete → disappears from pending filter
- ✓ Toggle back to incomplete → reappears
- ✓ Empty state shows: "All caught up!"

### Completed Tasks Filter
- ✓ Complete a task → should appear in this filter
- ✓ Delete completed task → removed
- ✓ Cannot edit completed task (edit button hidden)
- ✓ Toggle to incomplete → disappears from completed filter
- ✓ Empty state shows: "No completed tasks"

### Reminders Filter
- ✓ Create task with past end date → appears in reminders
- ✓ Delete from reminders → removed
- ✓ Complete overdue task → disappears from reminders
- ✓ Empty state shows: "No reminders"

## Responsive Design Test

Test loading states on different device sizes:

- ✓ Mobile (< 600dp width)
  - Buttons clearly visible
  - Loading spinner appropriately sized
  - Text readable

- ✓ Tablet (600-1200dp width)
  - Dialog properly positioned
  - Spinner scaled appropriately
  - All controls accessible

- ✓ Desktop (≥ 1200dp width)
  - Dialog sized correctly
  - Large enough controls
  - Professional appearance

## Network Simulation Notes

The app simulates 3-second delays to mimic:
- Network latency
- Server processing time
- Database operations

In production, replace the artificial delay with actual API calls:
```dart
// Current (3 seconds simulated)
await Future.delayed(const Duration(seconds: 3));

// Future: Replace with actual API
// var response = await repository.createTask(...);
```

## Success Criteria

All tests pass when:
1. ✓ All loading states display correctly
2. ✓ All operations complete successfully
3. ✓ Error handling works as expected
4. ✓ No duplicate operations occur
5. ✓ UI remains responsive during loading
6. ✓ Visual feedback is clear and professional
7. ✓ Counters update correctly
8. ✓ Filters work with loading states
9. ✓ Empty states show appropriately
10. ✓ No console errors or warnings

