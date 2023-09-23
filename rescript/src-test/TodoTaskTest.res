open RescriptMocha
open Mocha
open TodoTask

describe("TodoTask", () => {
    it("switchChecked", () => {
        let given: TodoTask.t = ({
            id: "8asjd98as",
            name: "kkkoliko",
            isReady: false
        })
        let nominal: TodoTask.t = ({
            id: "8asjd98as",
            name: "kkkoliko",
            isReady: true
        })
        let result = TodoTask.switchChecked(given)
        Assert.deep_equal(nominal, result)
    })
})