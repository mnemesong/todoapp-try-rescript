open TodoBrowserManager
open TodoStateManager

module TodoServiceInBrowser = 
    TodoService.TodoService(TodoBrowserManager, TodoStateManager)

TodoServiceInBrowser.rerenderClearForm(TodoServiceInBrowser.applyForm)
TodoServiceInBrowser.rerenderResponsibles(TodoServiceInBrowser.changeTask)