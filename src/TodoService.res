module type ITodoBrowserManager = {
    let readFormVal: () => Belt.Result.t<string, string>
    let renderClearForm: () => Belt.Result.t<unit, string>
    let renderResponsibles: 
        (array<TodoResponsible.t>) => Belt.Result.t<unit, string>
    let setFormOnApplyAction: (() => Belt.Result.t<unit, string>) => Belt.Result.t<unit, string>
    let setTaskOnClickAction: (string, (string) => Belt.Result.t<unit, string>) => Belt.Result.t<unit, string>
}

module type ITodoStateManager = {
    let readResponsiblesState: 
        () => Belt.Result.t<array<TodoResponsible.t>, string>
    let writeResponsiblesState: 
        (array<TodoResponsible.t>) => Belt.Result.t<unit, string>
}

module TodoService = (TBM: ITodoBrowserManager, TSM: ITodoStateManager) => {
    let rerenderClearForm = 
        (applyForm: () => Belt.Result.t<unit, string>): unit => {
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
            Belt.Array.concat(acc, el.tasks)
    
    let rerenderResponsibles = 
        (changeTaskFun: (string) => Belt.Result.t<unit, string>): unit => {
            switch(TSM.readResponsiblesState()) {
                | Ok(state) => {
                    switch(TBM.renderResponsibles(state)) {
                        | Ok(a) => {
                            let tasks = Belt.Array.reduce(
                                state, 
                                []: array<TodoTask.t>, 
                                collectTasks
                            )
                            let setTaskResults = Belt.Array.map(
                                tasks, 
                                (t) => TBM.setTaskOnClickAction(t.id, changeTaskFun)
                            )
                            let errorMsgs = Belt.Array.map(
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
                                Js.Console.log("")
                            }
                        }
                        | Error(errMsg) => Js.Console.log2("Error: ", errMsg)
                    }
                }
                | Error(errMsg) => Js.Console.log2("Error: ", errMsg)
            }
        }

    let rec changeTask = 
        (taskId: string): Belt.Result.t<unit, string> => {
            switch(TSM.readResponsiblesState()) {
                | Error(errMsg) => Error(errMsg)
                | Ok(resps) => {
                    let newResps = Belt.Array.map(
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
        (): Belt.Result.t<unit, string> => {
            let setStateResult = switch(TBM.readFormVal()) {
            |   Error(errMsg) => Error(errMsg)
            |   Ok(formVal) => switch TSM.readResponsiblesState() {
                |   Error(errMsg) => Error(errMsg)
                |   Ok(resps) => Belt.Array.map(
                        resps, 
                        (r) => TodoResponsible.addTask(r, TodoTask.new(formVal))
                    ) -> TSM.writeResponsiblesState
                }
            }
            switch(setStateResult) {
                | Ok(_) => {
                    rerenderClearForm(applyForm)
                    Ok()
                }
                | Error(errMsg) => Error(errMsg)
            }
        }
    
    let changeChecked =
        (taskId: string): Belt.Result.t<unit, string> => 
            switch (TSM.readResponsiblesState()) {
            | Error(errMsg) => Error(errMsg)
            | Ok(rs) => rs
                ->  Belt.Array.map(r => switch(
                        TodoResponsible.switchChekedTask(r, taskId)
                    ) {
                    | Ok(rr) => rr
                    | Error(_) => r
                })
                ->  TSM.writeResponsiblesState
            }

}