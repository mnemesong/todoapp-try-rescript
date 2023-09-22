module TodoBrowserManager :TodoService.ITodoBrowserManager = {
    open Belt
    open TodoResponsible

    let readFormVal = (): Result.t<string, string> => try {
        let result = %raw(`
            function() {
                const v = document.getElementById("formInput").value;
                if(typeof v !== "string") {
                    throw new Error("unknown type of formInput");
                }
            }
        `)
        Result.Ok(result())
    } catch {
        | Js.Exn.Error(obj) => Result.Error(switch Js.Exn.message(obj) {
            | Some(msg) => msg
            | None => ""
        })
    }

    let renderClearForm = (): Result.t<unit, string> => try {
        let result: () => unit = %raw(`
            function() {
                const formContainer = document.getElementById("formContainer")
                if(!formContainer) {
                    throw new Error("Can not find formContainer")
                }
                formContainer.innerHTML = "<div>"
                    + "<input type='text' id='formInput'>"
                    + "<button type='button' id='formBtn'>Submit</button>"
                    + "</div>"
            }
        `)
        Result.Ok(result())
    } catch {
        | Js.Exn.Error(obj) => Result.Error(switch Js.Exn.message(obj) {
            | Some(msg) => msg
            | None => ""
        })
    }
    let renderResponsibles =
        (resps: array<TodoResponsible.t>): Result.t<unit, string> => try {
            let result: (array<TodoResponsible.t>) => unit = %raw(`
                function(resps) {
                    // renderTask :: Task -> string
                    const renderTask = (task) => "<li id='task_" + task.id +"'>"
                        + (task.isReady ? "<b>" : "")
                        + task.name
                        + (task.isReady ? "</b>" : "")
                        + "</li>";
                    //renderResp :: Responsible -> string
                    const renderResp = (resp) => "<div>"
                        + "<span>" + resp.name + "</span>"
                        + "<ul>" + resp.tasks.map(t => renderTask(t)).join() + "</ul>"
                        + "</div>";
                    const respsHtml = resps.map(r => renderResp(r)).join();
                    const respsContainer = document.getElementById("respsContainer");
                    if(!respsContainer) {
                        throw new Error("Can not find respsContainer");
                    }
                    respsContainer.innerHTML = respsHtml;
                }
            `)
            Result.Ok(result(resps))
        } catch {
            | Js.Exn.Error(obj) => Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }
    
    
    let setFormOnApplyAction = (
            appForm: () => Result.t<unit, string>
        ): Result.t<unit, string> => try {
            let result: (() => Result.t<unit, string>) => unit = %raw(`
                function(appFormFun) {
                    const formBtn = document.getElementById("formBtn");
                    if(!formBtn) {
                        throw new Error("unknown type of formBtn");
                    }
                    formBtn.onclick = appFormFun;
                }
            `)
            Result.Ok(result(appForm))
        } catch {
            | Js.Exn.Error(obj) => Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }

    let setTaskOnClickAction = (
        taskId: string, 
        changeTaskFun: (string) => Result.t<unit, string>
    ): Result.t<unit, string> => try {
            let result: (string, (string) => Result.t<unit, string>) => unit = %raw(`
                function(taskId, changeTaskFun) {
                    const curTask = document.getElementById('task_' + taskId);
                    curTask.onclick = () => changeTaskFun(taskId);
                }
            `)
            Result.Ok(result(taskId, changeTaskFun))
        } catch {
            | Js.Exn.Error(obj) => Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }
}