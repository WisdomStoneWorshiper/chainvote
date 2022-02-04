const eoslime = require('eoslime').init();
const { doesNotMatch } = require('assert');
const assert = require("assert");
const { isTypedArray } = require('util/types');
require("dotenv").config();

const CONTRACT_WASM_PATH = "../votingplat/votingplat.wasm";
const CONTRACT_ABI_PATH = "../votingplat/votingplat.abi"

describe("Testing for contract", async function() {

    this.timeout(100000)

    let contractAccount, contract;
    let userAccount1, userAccount2;


    before( async function () {
        userAccount1 = await eoslime.Account.createRandom();
        userAccount2 = await eoslime.Account.createRandom();
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

        it('Should create new voter', function(){
            contract.actions.
            createvoter(userAccount1.name)
            .then(res1 => {
                eoslime
                .Provider
                .select("voter").from(contractAccount.name)
                .equal(userAccount1.name).find()
                .then( res2 => {
                    assert.equal(res2.length, 1);
                })
            })
            .catch( err => {
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
                console.log(err)
                console.log("enter2")
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
                console.log(err);
                console.log("enter3")
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
                console.log(err);
                console.log("enter4")
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


});




