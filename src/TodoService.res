module type ITodoBrowserManager = {
    let readFormVal: () => Belt.Result.t<string, string>
    let renderClearForm: () => Belt.Result.t<unit, string>
    let renderResponsibles: 
        (array<TodoResponsible.t>) => Belt.Result.t<unit, string>
    let setFormOnApplyAction: (() => Belt.Result.t<unit, string>) => Belt.Result.t<unit, string>
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
    
    let rerenderResponsibles = 
        (): unit => {
            switch(TSM.readResponsiblesState()) {
                | Ok(state) => {
                    switch(TBM.renderResponsibles(state)) {
                        | Ok(a) => a
                        | Error(errMsg) => Js.Console.log2("Error: ", errMsg)
                    }
                }
                | Error(errMsg) => Js.Console.log2("Error: ", errMsg)
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