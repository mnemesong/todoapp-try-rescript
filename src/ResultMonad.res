module ResultMonad = {
    open Belt

    type t<'a> = Result.t<'a, string>

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