#  Planning

* Go through each view and review dynamic text size and long names
* Audit
* Add more todos to .previewSeed (ask chatgpt)
* Create DisplayTodos and DisplayLists for views, instead of passing around raw Todos and TodoLists
* Sheet model stored in parent view, causing unwanted persistence of state
* New app name
* NewTodoView should autofocus title on appear
* background task that occasionally rebalances ranks if any one rank exceeds a certain length
* .task(model.fetch) doesn't work in EditTodoView, reruns when navigating back from list picker
* newTodoView textfields not working in preview

# Future
* Make Dashboard search bar a circle button instead in bottom right
* Soft-delete lists
* Add support for FTS5 (full text search)
* Make Dashboard edit button use checkmark on iOS 26
* When entering edit mode on Dashboard, Scheduled list animates from leading edge when the 
others don't
