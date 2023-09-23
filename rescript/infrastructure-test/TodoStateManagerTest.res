open RescriptMocha
open Mocha
open TodoStateManager
open Belt

describe("TodoStateManager", () => {
    it("test 1", () => {
        let initResult = TodoStateManager.writeResponsiblesState(
            TodoStateManager.initNominalData()
        )
        Assert.deep_equal(Result.Ok(), initResult)
        let readResult = 
            Result.getExn(TodoStateManager.readResponsiblesState())
        Assert.deep_equal(readResult, TodoStateManager.initNominalData())
    })
})