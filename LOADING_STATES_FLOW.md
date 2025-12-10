# Loading States Flow Diagram

## Operation Flow: Create/Edit Task

```
User clicks "Create" button
         ↓
Dialog shows loading spinner in icon
         ↓
Button text changes to "Loading..."
         ↓
Input fields become disabled
         ↓
Wait 3 seconds (simulated network call)
         ↓
Repository operation executes
         ↓
State updates with new todo list
         ↓
Loading state → false
         ↓
Dialog closes automatically
         ↓
SnackBar shows "Task created/updated successfully!" (green)
         ↓
Success message auto-clears after 2 seconds
```

## Operation Flow: Delete Task

```
User clicks delete button on todo item
         ↓
Delete confirmation dialog appears
         ↓
User clicks "Delete" button
         ↓
Dialog shows loading spinner (red)
         ↓
Button text changes to "Deleting..."
         ↓
All buttons become disabled
         ↓
Wait 3 seconds (simulated network call)
         ↓
Repository operation executes
         ↓
Todo removed from list
         ↓
Loading state → false
         ↓
Dialog closes automatically
         ↓
SnackBar shows "Task deleted successfully!" (green)
```

## Operation Flow: Toggle Task (Checkbox)

```
User clicks checkbox on todo item
         ↓
toggleLoadingProvider set to todo id
         ↓
Checkbox icon turns grey
         ↓
Edit button becomes lighter/disabled
         ↓
Delete button becomes lighter/disabled
         ↓
Wait 3 seconds (simulated network call)
         ↓
Repository operation executes
         ↓
Todo.completed flipped
         ↓
State updates
         ↓
Toggle loading → null
         ↓
Colors return to normal
         ↓
Item updates with new completed state
         ↓
Counters update (pending/completed)
```

## State Management Architecture

```
┌─────────────────────────────────────────────────────┐
│         Loading State Providers                      │
├─────────────────────────────────────────────────────┤
│ • createLoadingProvider (bool)                       │
│ • editLoadingProvider (bool)                         │
│ • deleteLoadingProvider (bool)                       │
│ • toggleLoadingProvider (String? = todo id)          │
│ • errorMessageProvider (String?)                     │
│ • successMessageProvider (String?)                   │
└────────────────┬────────────────────────────────────┘
                 │
                 ↓
         ┌──────────────┐
         │ TodosNotifier│
         │              │
         │ addTodo()    │
         │ editTodo()   │
         │ deleteTodo() │
         │ toggleTodo() │
         └──────┬───────┘
                │
         ┌──────↓────────┐
         │ UI Components │
         │               │
         │ Dialogs       │
         │ Todo Items    │
         │ SnackBars     │
         └───────────────┘
```

## Visual States

### Create/Edit Dialog States

**Normal State:**
- Icon with edit/note icon
- Title: "Create task" or "Edit task"
- Enabled input fields
- Enabled time pickers
- Blue "Create"/"Save" button

**Loading State:**
- Spinner (blue) in place of icon
- Button text: "Loading..."
- Disabled input fields (greyed out)
- Disabled time pickers (greyed out)
- Disabled buttons (grey color)
- Cannot dismiss dialog (PopScope)

**Success State:**
- Dialog closes
- SnackBar: Green background
- Message: "Task created/updated successfully!"
- Auto-dismiss after 2 seconds

### Delete Dialog States

**Normal State:**
- Icon with delete/sweep icon (red)
- "Delete Task" title
- Red "Delete" button

**Loading State:**
- Spinner (red) in place of icon
- Button text: "Deleting..."
- Disabled buttons (grey)
- Cannot dismiss dialog (PopScope)

**Success State:**
- Dialog closes
- SnackBar: Green background
- Message: "Task deleted successfully!"

### Todo Item States

**Normal State:**
- Colored checkbox (blue when unchecked, blue when checked)
- Colored edit button (grey)
- Colored delete button (red)

**Toggling State:**
- Grey checkbox (disabled)
- Light grey edit button (disabled)
- Light red delete button (disabled)
- Item slightly dimmed (visual feedback)

## Error Handling

If an operation fails:

```
Operation Error Occurs
         ↓
Loading state → false
         ↓
Error message set (e.g., "Failed to create task: exception")
         ↓
Dialog closes (if applicable)
         ↓
SnackBar shows error message (red background)
         ↓
Error auto-clears after 3 seconds
         ↓
User can retry operation
```

## Time Diagram

```
Timeline: Create Task Operation

0s      ┌─ User clicks "Create"
        │  • createLoadingProvider = true
        │  • Dialog shows spinner
        │  • Button disabled
        │
1.5s    │
        │
3s      └─ Delay ends
        │  • Repository operation executes
        │  • State updates
        │  • createLoadingProvider = false
        │
3.1s    ┌─ Dialog closes
        │  • successMessageProvider = "Task created successfully!"
        │
3.2s    │
        │
5s      └─ SnackBar auto-dismisses
           • successMessageProvider = null
```

## Button Disable Logic

```dart
// Create/Edit Dialog Buttons
onPressed: isLoading ? null : () => _handleSave(ref)

// Delete Dialog Buttons
onPressed: isLoading ? null : () => { /* action */ }

// Todo Item Buttons
onTap: isToggling ? () {} : onTapCheckBox  // callback does nothing if toggling
```

When `onPressed` is null, Flutter automatically disables the button and greys it out.

## SnackBar Display

```
HomeScreen watches providers:
  - successMessageProvider
  - errorMessageProvider

When values change:
  ↓
WidgetsBinding.addPostFrameCallback() triggers
  ↓
SnackBar shown via ScaffoldMessenger
  ↓
Success: Green, 2 second duration
Error:   Red, 3 second duration
```

## User Feedback Summary

| Operation | Loading Indicator | Button State | Message | Duration |
|-----------|-------------------|--------------|---------|----------|
| Create | Blue spinner | Disabled, "Loading..." | "Task created successfully!" | 3s + 2s |
| Edit | Blue spinner | Disabled, "Loading..." | "Task updated successfully!" | 3s + 2s |
| Delete | Red spinner | Disabled, "Deleting..." | "Task deleted successfully!" | 3s + 2s |
| Toggle | Icon greyed | Disabled | None | 3s |
| Error | None | Back to normal | "Failed to [action]..." | 3s |

