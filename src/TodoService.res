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

module TodoServicePrivate = {
    open Belt
    open TodoTask
    open TodoResponsible
    open ResultMonad

    let collectTasks = 
        (acc: array<TodoTask.t>, el: TodoResponsible.t) => 
            Array.concat(acc, el.tasks)

    let collectTasksFromRespsArray = 
        (state) => Array.reduce(
            state, 
            []: array<TodoTask.t>, 
            collectTasks
        )

    let collectManyErrorMsgs = 
        (results: array<ResultMonad.t<unit>>) => 
            Array.map( results, (tr) => 
                switch(tr) {
                    | Error(errMsg) => errMsg
                    | Ok(_) => ""
                }
            ) -> Js.String.concatMany("")

    let summaryErrorMsgsToResut = 
        (errorMsg: string) =>
            (Js.String.length(errorMsg) > 0)
                ? Error("SetTaskErrors: " ++ errorMsg)
                : Ok()
}

module TodoService = (TBM: ITodoBrowserManager, TSM: ITodoStateManager) => {
    open Belt
    open TodoResponsible
    open TodoTask
    open ResultMonad
    open TodoServicePrivate

    let rerenderClearForm = 
        (applyForm: () => Result.t<unit, string>): unit => {
            let result = TBM.renderClearForm()
                -> ResultMonad.bind(() => TBM.setFormOnApplyAction(applyForm))
            switch(result) {
                | Ok(_) => ()
                | Error(errMsg) => Js.Console.log2("Error:", errMsg)
            }
        }
    
    let rerenderResponsibles = 
        (changeTaskFun: (string) => Result.t<unit, string>): unit => {
            let result = TSM.readResponsiblesState()
                -> ResultMonad.bind(state => TBM.renderResponsibles(state))
                -> ResultMonad.bind(() => TSM.readResponsiblesState())
                -> ResultMonad.map(collectTasksFromRespsArray)
                -> ResultMonad.bind(tasks => {
                    Array.map( tasks,  (t) => 
                        TBM.setTaskOnClickAction(t.id, changeTaskFun)
                    ) -> collectManyErrorMsgs
                    -> summaryErrorMsgsToResut
                })
            switch result {
                | Ok(_) => ()
                | Error(errMsg) => { Js.Console.log(errMsg) }
            }
            
        }

    let rec changeTask = 
        (taskId: string): Result.t<unit, string> => {
            TSM.readResponsiblesState()
                -> ResultMonad.map(resps => Array.map(resps, (r) => {
                        TodoResponsible.tryToSwitchChackedTask(r, taskId)
                    }
                ))
                -> ResultMonad.bind(TSM.writeResponsiblesState)
                -> ResultMonad.map(() => rerenderResponsibles(changeTask))
        }

    let rec applyForm = 
        (): Result.t<unit, string> => {
            (TBM.readFormVal(), TSM.readResponsiblesState())
                -> ResultMonad.liftTuple
                -> ResultMonad.map((tuple) => {
                    let (formVal, resps) = tuple
                    Array.map( resps, (r) => 
                        TodoResponsible.addTask(r, TodoTask.new(formVal))
                    )
                })
                -> ResultMonad.bind(TSM.writeResponsiblesState)
                -> ResultMonad.map(() => rerenderClearForm(applyForm))
                -> ResultMonad.map(() => rerenderResponsibles(changeTask))
        }
    
    let changeChecked =
        (taskId: string): Result.t<unit, string> => {
            TSM.readResponsiblesState()
                -> ResultMonad.bind(rs => Array.map(rs, r => 
                    TodoResponsible.tryToSwitchChackedTask(r, taskId)
                ) -> TSM.writeResponsiblesState)
        }

}