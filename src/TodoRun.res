module TodoBrowserManager :TodoService.ITodoBrowserManager = {

    let readFormVal = (): Belt.Result.t<string, string> => try {
        let result = %raw(`
            function() {
                const v = document.getElementById("formInput").value;
                if(typeof v !== "string") {
                    throw new Error("unknown type of formInput");
                }
            }
        `)
        Belt.Result.Ok(result())
    } catch {
        | Js.Exn.Error(obj) => Belt.Result.Error(switch Js.Exn.message(obj) {
            | Some(msg) => msg
            | None => ""
        })
    }

    let renderClearForm = (): Belt.Result.t<unit, string> => try {
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
        Belt.Result.Ok(result())
    } catch {
        | Js.Exn.Error(obj) => Belt.Result.Error(switch Js.Exn.message(obj) {
            | Some(msg) => msg
            | None => ""
        })
    }
    let renderResponsibles =
        (resps: array<TodoResponsible.t>): Belt.Result.t<unit, string> => try {
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
            Belt.Result.Ok(result(resps))
        } catch {
            | Js.Exn.Error(obj) => Belt.Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }
    
    
    let setFormOnApplyAction = (
            appForm: () => Belt.Result.t<unit, string>
        ): Belt.Result.t<unit, string> => try {
            let result: (() => Belt.Result.t<unit, string>) => unit = %raw(`
                function(appFormFun) {
                    const formBtn = document.getElementById("formBtn");
                    console.log(formBtn)
                    if(!formBtn) {
                        throw new Error("unknown type of formBtn");
                    }
                    formBtn.onclick = appFormFun;
                }
            `)
            Belt.Result.Ok(result(appForm))
        } catch {
            | Js.Exn.Error(obj) => Belt.Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }

    let setTaskOnClickAction = (
        taskId: string, 
        changeTaskFun: (string) => Belt.Result.t<unit, string>
    ): Belt.Result.t<unit, string> => try {
            let result: (string, (string) => Belt.Result.t<unit, string>) => unit = %raw(`
                function(taskId, changeTaskFun) {
                    const curTask = document.getElementById('task_' + taskId);
                    curTask.onclick = changeTaskFun;
                }
            `)
            Belt.Result.Ok(result(taskId, changeTaskFun))
        } catch {
            | Js.Exn.Error(obj) => Belt.Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }
}

%%raw(`
    let globState = [
        {
            id: "cfddfeec-436c-413b-8ea4-dc3bbd40cd53",
            name: "Mary",
            tasks: [
                {
                    id: "5b72058d-d1f9-4192-8fbd-74b63549ec6f",
                    name: "Power up PC",
                    isReady: false,
                },
                {
                    id: "50acd125-4a6e-4af9-8fe1-2f5ae486c1c2",
                    name: "Groove the cat",
                    isReady: true,
                }
            ]
        }
    ]
`)
module TodoStateManager :TodoService.ITodoStateManager = {
    let readResponsiblesState = 
        (): Belt.Result.t<array<TodoResponsible.t>, string> => try {
            let result: array<TodoResponsible.t> = %raw(`
                globState
            `)
            Belt.Result.Ok(result)
        } catch {
            | Js.Exn.Error(obj) => Belt.Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }

    let writeResponsiblesState =
        (newResps: array<TodoResponsible.t>): Belt.Result.t<unit, string> => try {
            let result: (array<TodoResponsible.t>) => unit = %raw(`
                function(resps) {
                    globState = resps;
                }
            `)
            Belt.Result.Ok(result(newResps))
        } catch {
            | Js.Exn.Error(obj) => Belt.Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }
}

module TodoServiceInBrowser = 
    TodoService.TodoService(TodoBrowserManager, TodoStateManager)

TodoServiceInBrowser.rerenderClearForm(TodoServiceInBrowser.applyForm)
TodoServiceInBrowser.rerenderResponsibles(TodoServiceInBrowser.changeTask)