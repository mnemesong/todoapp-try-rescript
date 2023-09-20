module TodoResponsible = {
    open Belt
    open TodoTask

    type t = {
        id: string,
        name: string,
        tasks: array<TodoTask.t>
    }

    let addTask = 
        (t: t, task: TodoTask.t): t => 
            Array.some(t.tasks, (tsk) => (tsk.id == task.id))
            ?  ({
                id: t.id,
                name: t.name,
                tasks: Array.map(
                    t.tasks, 
                    (tsk) => (tsk.id == task.id) ? task : tsk
                )
            })
            : ({
                id: t.id,
                name: t.name,
                tasks: Array.concat(t.tasks, [task])
            })

    let switchChekedTask = 
        (t: t, taskId: string): Result.t<t, string> => 
            Array.some(t.tasks, (tsk) => (tsk.id == taskId))
            ? Ok({
                id: t.id,
                name: t.name,
                tasks: t.tasks
                    -> Array.map((tt) => (tt.id == taskId) 
                        ? TodoTask.switchChecked(tt) 
                        : tt
                    )
            })
            : Error("Can not find Task in Responsible by taskId")
}