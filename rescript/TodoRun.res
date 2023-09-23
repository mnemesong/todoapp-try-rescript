open TodoBrowserManager
open TodoStateManager
open Belt

Result.getExn(
    TodoStateManager.writeResponsiblesState(TodoStateManager.initNominalData())
)

module TodoServiceInBrowser = 
    TodoService.TodoService(TodoBrowserManager, TodoStateManager)

TodoServiceInBrowser.rerenderClearForm(TodoServiceInBrowser.applyForm)
TodoServiceInBrowser.rerenderResponsibles(TodoServiceInBrowser.changeTask)