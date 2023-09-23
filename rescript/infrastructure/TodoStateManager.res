%%raw(`
    let globState = []
`)

module type ITodoStateManagerAdv = {
    open TodoResponsible
    open TodoService

    include ITodoStateManager

    let initNominalData: 
        () => array<TodoResponsible.t>
}

module TodoStateManager: ITodoStateManagerAdv = {
    open Belt
    open TodoResponsible

    let readResponsiblesState = 
        (): Result.t<array<TodoResponsible.t>, string> => try {
            let result: array<TodoResponsible.t> = %raw(`
                globState
            `)
            Result.Ok(result)
        } catch {
            | Js.Exn.Error(obj) => Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }

    let writeResponsiblesState =
        (newResps: array<TodoResponsible.t>): Result.t<unit, string> => try {
            let result: (array<TodoResponsible.t>) => unit = %raw(`
                function(resps) {
                    globState = resps;
                }
            `)
            Result.Ok(result(newResps))
        } catch {
            | Js.Exn.Error(obj) => Result.Error(switch Js.Exn.message(obj) {
                | Some(msg) => msg
                | None => ""
            })
        }

    let initNominalData = 
        (): array<TodoResponsible.t> => 
            [{
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
            }]
}