const eoslime = require('eoslime').init();
const { doesNotMatch } = require('assert');
const assert = require("assert");
const { isTypedArray } = require('util/types');
require("dotenv").config();

const CONTRACT_WASM_PATH = "../votingplat/votingplat.wasm";
const CONTRACT_ABI_PATH = "../votingplat/votingplat.abi"

const DAY_OFFSET = new Date(1000 * 3600 *24);

function getRandomString(length) {
    var randomChars = 'abcdefghijklmnopqrstuvwxyz';
    var result = '';
    for ( var i = 0; i < length; i++ ) {
        result += randomChars.charAt(Math.floor(Math.random() * randomChars.length));
    }
    return result;
}

describe("Testing for contract", async function() {

    this.timeout(100000)

    let contractAccount, contract;
    let userAccount1, userAccount2;


    before( async function () {
        userAccount1 = await eoslime.Account.createFromName(getRandomString(12));
        userAccount2 = await eoslime.Account.createFromName(getRandomString(12));
    });

    describe("createvoter", async function(){
        beforeEach( async function() {
            contractAccount = await eoslime.Account.createRandom();
            contract = await eoslime.Contract.deployOnAccount(
                CONTRACT_WASM_PATH,
                CONTRACT_ABI_PATH,
                contractAccount
            );
        })

        it('Should create new voter', async function(){
            await contract.actions.
            createvoter({ "createvoter.new_voter" : userAccount1})
            .then(async res1 => {
                console.log(res1.transaction.transaction.actions)
                await eoslime
                .Provider
                .select("voter").from(contractAccount.name)
                .equal(userAccount1.name).find()
                .then( res2 => {
                    console.log(res2)
                    assert.equal(res2, 1);
                })
            })
            .catch( err => {
                console.log(err)
                assert.fail("failed trans")
            })
        });

        it('Should not have duplicated voter', async function(){
            await contract.actions
            .createvoter(userAccount1.name)
            .catch( err => {
                console.log(err.message)
                assert.fail(`Failed to initialize table before testing`)
            })

            contract.actions.
            createvoter(userAccount1.name)
            .then(res1 => {
                assert.fail( "Transaction should not be successful")
            })
            .catch(err => {
                // console.log(err)
                // console.log("enter2")
                eoslime
                .Provider
                .select("voter").from(contractAccount.name)
                .equal(userAccount1.name).find()
                .then( res2 => {
                    assert.equal(
                        err.details[0].message, 
                        "assertion failure with message: voter exist");
                    assert.equal(res2.length, 1);
                })
            })
        })

        it('Should not create voter without admin account', async function() {
            await contract.actions.
            createvoter(userAccount2.name,{from : userAccount1})
            .then(res => {
                assert.fail( "Transaction should not be successful")
            })
            .catch( err => {
                // console.log(err);
                // console.log("enter3")
                eoslime
                .Provider
                .select("voter").from(contractAccount.name)
                .equal(userAccount2.name).find()
                .then( res => {
                    assert.equal(err.error.name, "missing_auth_exception")
                    assert.equal(res.length, 0);
                })
            })
        })

        it('Should not create voter with own account', async function(){
            await contract.actions
            .createvoter(userAccount1.name, {from : userAccount1})
            .then(res => {
                assert.fail("Transaction should not be successful")
            })
            .catch( err => {
                // console.log(err);
                // console.log("enter4")
                eoslime
                .Provider
                .select("voter").from(contractAccount.name)
                .equal(userAccount2.name).find()
                .then( res => {
                    assert.equal(err.error.name, "missing_auth_exception")
                    assert.equal(res.length, 0);
                })
            })
        })
    });

    describe("createcamp", function(){
        let currentDate = new Date();
        let startTime = new Date( currentDate.getTime() + DAY_OFFSET.getTime());
        let endTime = new Date( currentDate.getTime() + 2 * DAY_OFFSET.getTime());


        beforeEach( async function() {

        const contractAbi = await eoslime.Provider.getABI("idk");
        const contractWasm = await eoslime.Provider .getRawWASM("idk")
            contractAccount = await eoslime.Account.createRandom();
            contract = await eoslime.Contract.deployRawOnAccount(
                contractWasm,
                contractAbi,
                contractAccount
            );

            console.log(userAccount1);

            await contract.actions
            .createvoter("sajkd")
            .then(res => {
                eoslime.Provider
                .select("voter").from(contractAccount.name)
                .find()
                .then(res => console.log(res));
            })
            .catch(err => {
                console.log(err)
                assert.fail(`Failed to initialize voter : ${userAccount1.name} to test createcamp`)
            })
        })

        it("Should create a campaign", async  function(){
            const filterStart = startTime.toISOString().split(".")[0]
            const filterEnd = endTime.toISOString().split(".")[0]
            await contract.actions.
            createcamp(
                userAccount1.name,
                "testcamp", 
                new Date(filterStart),
                new Date(filterEnd),
                {from : userAccount1})
            .catch( err => {
                console.log(err)
                assert.fail("failed trans")
            })

            let voterTable = await eoslime.Provider
            .select("voter").from(contractAccount.name)
            .equal(userAccount2.name).find()

            let campaignTable = await eoslime.Provider
            .select("campaign").from(contractAccount.name)
            .equal(0).find()

            console.log(voterTable)
            console.log(campaignTable)

            assert.equal(0, voterTable[0].owned_campaign[0]);
            assert.equal("testcamp", campaignTable[0].campaign_name);
            assert.equal(userAccount1.name, campaignTable[0].owner);
        })


    })

});




