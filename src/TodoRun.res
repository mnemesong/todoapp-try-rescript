module TodoBrowserManager /*:ITodoBrowserManager*/ = {

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
                    const renderTask = (task) => "<li>"
                        + (task.isReady ? "<b>" : "")
                        + task.name
                        + (task.isReady ? "</b>" : "")
                        + "</li>";
                    //renderResp :: Responsible -> string
                    const renderResp = (resp) => "<li>"
                        + "<div>" + resp.name + "</div>"
                        + "<ul>" + resp.tasks.map(t => renderTask(t)).join() + "</ul>"
                        + "</li>";
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
                    const formBtn = document.getElementById("formBtn")
                    if(!formBtn) {
                        throw new Error("unknown type of formBtn");
                    }
                    formBtn.onchange = appFormFun
                }
            `)
            Belt.Result.Ok(result(appForm))
        } catch {
            | Js.Exn.Error(obj) => Belt.Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }
}