const express = require("express");
const router = express.Router();

const accModel = require("../../Helper functions/mongoose/accModel");
const eosDriver = require("../../Helper functions/eosDriver");
const { addVoterPlaceholder, delVoterPlaceholder } = require("../../Helper functions/eosPlaceholder");
const Account = require("../../Helper functions/mongoose/accModel");
require("dotenv").config();

router.post("/addvoter", async (req, res) => {
    const { itsc = [], campaignId = 0, owner = "" } = req.body;
    console.log("enter addvoter")

    let ownerData = await Account.findOne( {itsc : owner});

    if(ownerData == null){
        res.status(400).json({
            error : true,
            message : "Cannot find ITSC user"
        });
        console.log("cannot find owner")
        return;
    }

    let accountList = [];
    let errorAccount = [];

    //find the campaign first
    const table = await eosDriver.rpc.get_table_rows({
        json: true,               // Get the response as json
        code: `${process.env.ACC_NAME}`,      // Contract that we target
        scope: `${process.env.ACC_NAME}`,         // Account that owns the data
        table: 'campaign',        // Table name,
        lower_bound : campaignId,
        limit: 1,                // Maximum number of rows that we want to get
        reverse: false,           // Optional: Get reversed data
        show_payer: false          // Optional: Show ram payer
    });
    // console.log(table)

    if(
        table["rows"].length == 0 || 
        table["rows"][0]["id"] != campaignId ||
        table["rows"][0]["owner"] != ownerData.accountName){
        res.status(400).json({
            error : true,
            message : "Cannot find specified campaignId"
        })
        return;
    }



    for(let i = 0; i < itsc.length; i++){
        try{
            const data = await accModel.findOne({itsc : itsc[i]});

            if (!data || !data.accountName) {
                errorAccount.push(itsc[i]);
            }
            else {
                accountList.push({
                    itsc: itsc[i],
                    acc: data.accountName
                });
            }
        }
        catch (e) {
            console.log("Unexpected error idk")
            console.log(e)
            errorAccount.push(itsc[i]);
        }
    }

    let promiseArray = []

    for (let i = 0; i < accountList.length; i++) {
        promiseArray.push(new Promise((resolve, reject) => {
            console.log(`adding ${accountList[i].acc} to the contract`)
            eosDriver.transact({
                actions: [
                    addVoterPlaceholder(accountList[i].acc, campaignId)
                ]
            },
                {
                    useLastIrreversible : true,
                    expireSeconds: 30,
                }
            )
            .then( result => {
                resolve()
            })
            .catch( err => {
                console.log(err)
                errorAccount.push(accountList[i].itsc)
                resolve();
            })
        }))
    }

    await Promise.all(promiseArray)
        .then(() => {
            if (errorAccount.length >= 1) {
                console.log("found error account")
                res.status(400).json({
                    error: true,
                    failed: errorAccount
                })
            }
            else {
                console.log("success")
                res.json({
                    error: false
                })
            }
        })

});

router.post("/delvoter", async (req, res) => {
    const { itsc = [], campaignId = 0, owner = "" } = req.body;
	console.log("enter delvoter");
	console.log(`${itsc} and ${campaignId} and ${owner})`);
    let ownerData = await Account.findOne( {itsc : owner});

    if(ownerData == null){
        res.status(400).json({
            error : true,
            message : "Cannot find ITSC user"
        });
        return;
    }

    const table = await eosDriver.rpc.get_table_rows({
        json: true,               // Get the response as json
        code: `${process.env.ACC_NAME}`,      // Contract that we target
        scope: `${process.env.ACC_NAME}`,         // Account that owns the data
        table: 'campaign',        // Table name,
        lower_bound : campaignId,
        limit: 1,                // Maximum number of rows that we want to get
        reverse: false,           // Optional: Get reversed data
        show_payer: false          // Optional: Show ram payer
    });

    let delvoterList = []
    let errorVoter = []

    for (let i = 0; i < table["rows"].length; i++) {
        if ((table["rows"][i]["id"] == campaignId) && (table["rows"][i]["owner"] == ownerData.accountName)) {
            console.log(`Target owner ${table["rows"][i]["owner"]}`)
            console.log(table["rows"][i]["voter_list"])
            for(let j = 0; j < itsc.length; j++){
                try{
                    const data = await accModel.findOne({itsc : itsc[j]});
                    const indexData = table["rows"][i]["voter_list"].indexOf(data.accountName);
                    if(indexData >= 0){
                        console.log(`User ${data.accountName} index found at ${indexData}`)
                        delvoterList.push({
                            acc: itsc[j],
                            index: indexData
                        })
                    }
                    else {
                        console.log("Not in array");
                        errorVoter.push(itsc[j]);
                    }            

                }
                catch(e){
                    errorVoter.push(itsc[j]);
                }
            }

        }
    }

    if(delvoterList.length <= 0){
        console.log("Failed to find campaign")
        console.log(ownerData)
        res.status(400).json({
            error : true,
            message : "Cannot find specified campaignId"
        });
        return;
    }

    let promiseArray = [] //this is quite stupid no?

    for(let i = 0; i < delvoterList.length; i++){
        promiseArray.push( new Promise( (resolve, reject) => {
            eosDriver.transact({
                actions: [delVoterPlaceholder(campaignId, delvoterList[i].index)]
            },
                {
                    useLastIrreversible : true,
                    expireSeconds: 30,
                }
            )
            .then( result => {
                console.log(`User ${delvoterList[i]} has been deleted`);
                resolve();
            })
            .catch( err => {
                errorVoter.push(delvoterList[i].acc)
                console.log(`User ${delvoterList[i]} has faield`)
                resolve();
            })
        }))
    }

    await Promise.all(promiseArray)
        .then(() => {
            if (errorVoter.length >= 1) {
                console.log("found error acc")
                res.status(400).json({
                    error: true,
                    failed: errorVoter
                })
            }
            else {
                console.log("success")
                res.json({
                    error: false
                })
            }
        })

});

router.post("/login", async (req, res) => {
    console.log("login in")
    const { itsc } = req.body;
    accModel.findOne({
        itsc : itsc,
    })
    .then( result => {
        console.log("success")
        res.json({
            error : false,
            accountName : (result.accountName != itsc) ? result.accountName : null
        });
    })
    .catch(err => {
        console.log("nope")
        res.status(500).json({
            error: true,
            message: err.message
        })
    })
});

router.post("/getITSC", async (req, res) => {
    const { accountName } = req.body;
    console.log("entering getITSC")
    accModel.findOne({
        accountName : accountName
    })
    .then( result => {
        if(accountName == result.itsc){
            console.log("account not created yet")
            res.status(500).json({
                error : true,
                message : "Account has not been created! (ITSC = AccountName)"
            })
        }
        else{
            console.log("success")
            res.json({
                error : false,
                itsc : result.itsc
            });
        }
        
    })
    .catch(err => {
        console.log("not linked")
        res.status(500).json({
            error: true,
            message: "This account name is not linked to any ITSC"
        })
    })
});

module.exports = router;
