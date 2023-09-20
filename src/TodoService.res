module type ITodoBrowserManager = {
    open Belt
    open TodoResponsible

    let readFormVal: () => Result.t<string, string>
    let renderClearForm: () => Result.t<unit, string>
    let renderResponsibles: 
        (array<TodoResponsible.t>) => Result.t<unit, string>
    let setFormOnApplyAction: (() => Result.t<unit, string>) => Result.t<unit, string>
    let setTaskOnClickAction: (string, (string) => Result.t<unit, string>) => Result.t<unit, string>
}

module type ITodoStateManager = {
    open Belt
    open TodoResponsible

    let readResponsiblesState: 
        () => Result.t<array<TodoResponsible.t>, string>
    let writeResponsiblesState: 
        (array<TodoResponsible.t>) => Result.t<unit, string>
}

module TodoService = (TBM: ITodoBrowserManager, TSM: ITodoStateManager) => {
    open Belt
    open TodoResponsible
    open TodoTask

    let rerenderClearForm = 
        (applyForm: () => Result.t<unit, string>): unit => {
            switch TBM.renderClearForm() {
                | Ok(_) => switch TBM.setFormOnApplyAction(applyForm) {
                    | Ok (_) => Js.Console.log("")
                    | Error(errMsg) => Js.Console.log2("Error:", errMsg)
                }
                | Error(errMsg) => Js.Console.log2("Error:", errMsg)
            }
        }

    let collectTasks = 
        (acc: array<TodoTask.t>, el: TodoResponsible.t) => 
            Array.concat(acc, el.tasks)
    
    let rerenderResponsibles = 
        (changeTaskFun: (string) => Result.t<unit, string>): unit => {
            switch(TSM.readResponsiblesState()) {
                | Ok(state) => {
                    switch(TBM.renderResponsibles(state)) {
                        | Ok(_) => {
                            let tasks = Array.reduce(
                                state, 
                                []: array<TodoTask.t>, 
                                collectTasks
                            )
                            let setTaskResults = Array.map(
                                tasks, 
                                (t) => TBM.setTaskOnClickAction(t.id, changeTaskFun)
                            )
                            let errorMsgs = Array.map(
                                setTaskResults,
                                (tr) => switch(tr) {
                                    | Error(errMsg) => errMsg
                                    | Ok(_) => ""
                                }
                            )
                            let errorMsg = Js.String.concatMany(errorMsgs, "")
                            if(Js.String.length(errorMsg) > 0) {
                                Js.Console.log2("SetTaskErrors: ", errorMsg)
                            } else {
                                ()
                            }
                        }
                        | Error(errMsg) => Js.Console.log2("Error: ", errMsg)
                    }
                }
                | Error(errMsg) => Js.Console.log2("Error: ", errMsg)
            }
        }

    let rec changeTask = 
        (taskId: string): Result.t<unit, string> => {
            Js.Console.log("changeTask function called")
            switch(TSM.readResponsiblesState()) {
                | Error(errMsg) => Error(errMsg)
                | Ok(resps) => {
                    let newResps = Array.map(
                        resps, 
                        (r) => {
                            switch(TodoResponsible.switchChekedTask(r, taskId)) {
                                | Error(_) => r
                                | Ok(nr) => nr
                            }
                        }
                    )
                    switch(TSM.writeResponsiblesState(newResps)) {
                        | Error(errMsg) => Error(errMsg)
                        | Ok() => {
                            rerenderResponsibles(changeTask)
                            Ok()
                        }
                    }
                }
            }
        }

    let rec applyForm = 
        (): Result.t<unit, string> => {
            let setStateResult = switch(TBM.readFormVal()) {
            |   Error(errMsg) => Error(errMsg)
            |   Ok(formVal) => switch TSM.readResponsiblesState() {
                |   Error(errMsg) => Error(errMsg)
                |   Ok(resps) => Array.map(
                        resps, 
                        (r) => TodoResponsible.addTask(r, TodoTask.new(formVal))
                    ) -> TSM.writeResponsiblesState
                }
            }
            switch(setStateResult) {
                | Ok(_) => {
                    rerenderClearForm(applyForm)
                    rerenderResponsibles(changeTask)
                    Ok()
                }
                | Error(errMsg) => Error(errMsg)
            }
        }
    
    let changeChecked =
        (taskId: string): Result.t<unit, string> => 
            switch (TSM.readResponsiblesState()) {
            | Error(errMsg) => Error(errMsg)
            | Ok(rs) => rs
                ->  Array.map(r => switch(
                        TodoResponsible.switchChekedTask(r, taskId)
                    ) {
                    | Ok(rr) => rr
                    | Error(_) => r
                })
                ->  TSM.writeResponsiblesState
            }

}