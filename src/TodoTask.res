type t = {
    id: string,
    name: string,
    isReady: bool,
}

let new = (name: string): t => ({
    id: Uuid.V4.make(),
    name: name,
    isReady: false
})

let switchChecked = (t: t) => ({
    id: t.id,
    name: t.name,
    isReady: !t.isReady
})