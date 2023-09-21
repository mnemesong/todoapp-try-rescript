module TodoResponsible = {
    open Belt
    open TodoTask

    type t = {
        id: string,
        name: string,
        tasks: array<TodoTask.t>
    }

    let withTasks = (t: t, tasks: array<TodoTask.t>): t => ({
        id: t.id,
        name: t.name,
        tasks: tasks
    })

    let addTask = 
        (t: t, task: TodoTask.t): t => 
            Array.some( t.tasks, (tsk) => (tsk.id == task.id) )
                ? withTasks( t, Array.map( 
                    t.tasks, 
                    (tsk) => TodoTask.refreshSame(tsk, task)
                ))
                : withTasks( t, Array.concat(t.tasks, [task]) )

    let switchChekedTask = 
        (t: t, taskId: string): Result.t<t, string> => 
            Array.some(t.tasks, (tsk) => (tsk.id == taskId))
                ? Ok(withTasks( t, Array.map(t.tasks, (tt) => 
                    (tt.id == taskId) ? TodoTask.switchChecked( tt ) : tt
                )))
                : Error("Can not find Task in Responsible by taskId")

    let tryToSwitchChackedTask = (t: t, taskId: string): t =>
        switch(switchChekedTask(t, taskId)) {
            | Error(_) => t
            | Ok(r) => r
        }
}