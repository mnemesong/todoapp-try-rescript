open RescriptMocha
open Mocha
open TodoResponsible

describe("TodoResponsible", () => {
    it("tryToSwitchChackedTask", () => {
        let given: TodoResponsible.t = ({
            id: "hdsa7hd899as",
            name: "Sam",
            tasks: [
                {
                    id: "89sad98saa",
                    name: "nd9a8s",
                    isReady: true
                },
                {
                    id: "9a0smfa",
                    name: "lpo,o-[p[",
                    isReady: false
                }
            ]
        })
        let result = TodoResponsible.tryToSwitchChackedTask(given, "9a0smfa")
        let nominal: TodoResponsible.t = ({
            id: "hdsa7hd899as",
            name: "Sam",
            tasks: [
                {
                    id: "89sad98saa",
                    name: "nd9a8s",
                    isReady: true
                },
                {
                    id: "9a0smfa",
                    name: "lpo,o-[p[",
                    isReady: true
                }
            ]
        })
        Assert.deep_equal(result, nominal)
    })
})