module ResultMonad = {
    open Belt

    type t<'a> = Result.t<'a, string>
    
    let pure = (a: 'a): t<'a> => Ok(a)

    let map = (a: t<'a>, f: 'a => 'b): t<'b> => switch(a) {
        | Ok(x) => Ok(f(x))
        | Error(errMsg) => Error(errMsg)
    }

    let bind = (a: t<'a>, f: 'a => t<'b>): t<'b> => switch(a) {
        | Ok(x) => f(x)
        | Error(errMsg) => Error(errMsg)
    }

    let liftTuple = (tuple: (t<'a>, t<'b>)): t<('a, 'b)> => {
        let (a, b) = tuple
        switch(a) {
            | Error(errMsg) => Error(errMsg)
            | Ok(aVal) => switch(b) {
                | Error(errMsg) => Error(errMsg)
                | Ok(bVal) => Ok(aVal, bVal)
            }
        }
    }
}