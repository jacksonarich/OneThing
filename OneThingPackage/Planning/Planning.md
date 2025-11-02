#  Planning

* Change todo_lists table `colorIndex` to be `colorKey` that is a text lookup key
* Improve date-to-string formatting (ex: tomorrow, next thursday)
* Add support for FTS5 (full text search)
* Make sure completed items can be deleted
* Moving deleted todos should undelete them
* Creating todos should only take a listID, all other columns should have default values (including rank!)
  * need a test rig for setting up database with preset todos (done)
