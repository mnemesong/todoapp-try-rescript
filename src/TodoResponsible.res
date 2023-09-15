type t = {
    id: string,
    name: string,
    tasks: array<TodoTask.t>
}

let addTask = 
    (t: t, task: TodoTask.t): t => 
        Belt.Array.some(t.tasks, (tsk) => (tsk.id == task.id))
        ?  ({
            id: t.id,
            name: t.name,
            tasks: Belt.Array.map(t.tasks, (tsk) => (tsk.id == task.id) ? task : tsk)
        })
        : ({
            id: t.id,
            name: t.name,
            tasks: Belt.Array.concat(t.tasks, [task])
        })

let switchChekedTask = 
    (t: t, taskId: string): Belt.Result.t<t, string> => 
        Belt.Array.some(t.tasks, (tsk) => (tsk.id == taskId))
        ? Ok({
            id: t.id,
            name: t.name,
            tasks: t.tasks
                -> Belt.Array.map((tt) => (tt.id == taskId) 
                    ? TodoTask.switchChecked(tt) 
                    : tt
                )
        })
        : Error("Can not find Task in Responsible by taskId")