const express = require("express");
const router = express.Router();

const accModel = require("../../Helper functions/mongoose/accModel");
const eosDriver = require("../../Helper functions/eosDriver");
const { addVoterPlaceholder, delVoterPlaceholder } = require("../../Helper functions/eosPlaceholder")
require("dotenv").config();

router.post("/addvoter", async (req, res) => {
    const { itsc, campaignId } = req.body;

    let accountList = [];
    let errorVoter = [];

    for(let i = 0; i < itsc.length; i++){
        try{
            const data = await accModel.findOne({itsc : itsc[i]});

            if(!data || !data.accountName){
                errorAccount.push(itsc[i]);
            }
            else{
                accountList.push({
                    itsc : itsc[i],
                    acc : data.accountName
                });
            }
        }
        catch(e){
            console.log("Unexpected error idk")
            console.log(e)
            errorAccount.push(itsc[i]);
        }
    }

    let promiseArray = []

    for(let i = 0; i < accountList.length; i++){
        promiseArray.push( new Promise( (resolve, reject) => {
            console.log(`adding ${accountList[i].acc} to the contract`)
            eosDriver.transact({
                actions : [ 
                    addVoterPlaceholder(accountList[i].acc, campaignId)
                ]
                },
                {
                    blocksBehind: 3,
                    expireSeconds: 30,
                }
            )
            .then( result => {
                resolve()
            })
            .catch( err => {
                errorVoter.push(delvoterList[i].itsc)
                console.log(`User ${delvoterList[i].itsc} has faield`)
                resolve();
            })
        }))
    }

    await Promise.all(promiseArray)
    .then( () => {
        if(errorAccount.length >= 1){
            res.status(400).json({
                error: true,
                failed : errorAccount
            })
        }
        else{
            res.json({
                error : false
            })
        }
    })

});

router.post("/delvoter", async (req, res) => {
    const { itsc, campaignId } = req.body;

    const table = await eosDriver.rpc.get_table_rows({
        json: true,               // Get the response as json
        code: `${process.env.ACC_NAME}`,      // Contract that we target
        scope: `${process.env.ACC_NAME}`,         // Account that owns the data
        table: 'campaign',        // Table name,
        lower_bound : campaignId,
        limit: 3,                // Maximum number of rows that we want to get
        reverse: false,           // Optional: Get reversed data
        show_payer: false          // Optional: Show ram payer
    });
    console.log(table);

    let delvoterList = []
    let errorVoter = []
    for (let i = 0; i < table["rows"].length; i++) {
        console.log(table["rows"][i]["id"]);
        if (table["rows"][i]["id"] == campaignId) {
            console.log(`Campaign found at id ${campaignId}`)
            console.log(table["rows"][i]["voter_list"])
            for(let j = 0; j < itsc.length; j++){
                try{
                    const data = await accModel.findOne({itsc : itsc[j]});
                    const indexData = table["rows"][i]["voter_list"].indexOf(data.accountName);
                    console.log(`Currently searching for voter ${data.accountName}`)
                    if(indexData >= 0){
                        console.log(`User ${data.accountName} index found at ${indexData}`)
                        delvoterList.push({
                            acc : itsc[j],
                            index : indexData
                        })
                    }
                    else{
                        console.log("Not in array");
                        errorVoter.append(itsc);
                    }            

                }
                catch(e){

                    console.log(e)
                    console.log("Voter error");
                    errorVoter.append(itsc);

                }
            }

        }
    }

    console.log("Current voter found");
    console.log(delvoterList);

    let promiseArray = [] //this is quite stupid no?

    for(let i = 0; i < delvoterList.length; i++){
        promiseArray.push( new Promise( (resolve, reject) => {
	    console.log(delvoterList[i]);
            eosDriver.transact({
                actions : [delVoterPlaceholder(campaignId, delvoterList[i].index)]},
                {
                    blocksBehind: 3,
                    expireSeconds: 30,
                }
            )
            .then( result => {
                console.log(`User ${delvoterList[i]} has been deleted`);
                resolve();
            })
            .catch( err => {
		console.log(err)
                errorVoter.push(delvoterList[i].acc)
                console.log(`User ${delvoterList[i]} has faield`)
                resolve();
            })
        }))
    }

    await Promise.all(promiseArray)
    .then( () => {
        if(errorVoter.length >= 1){
            res.status(400).json({
                error: true,
                failed : errorVoter
            })
        }
        else{
            res.json({
                error : false
            })
        }
    })

});

router.post("/login", async (req, res) => {
    const { itsc } = req.body;
    accModel.findOne({
        itsc : itsc,
    })
    .then( result => {
        res.json({
            error : false,
            accountName : (result.accountName != itsc) ? result.accountName : null
        });
    })
    .catch( err => {
        res.status(500).json({
            error : true,
            message : err.message
        })
    })
});

router.post("/getITSC", async (req, res) => {
    const { accountName } = req.body;
    accModel.findOne({
        accountName : accountName
    })
    .then( result => {
        if(accountName == result.itsc){
            res.status(500).json({
                error : true,
                message : "Account has not been created! (ITSC = AccountName)"
            })
        }
        else{
            res.json({
                error : false,
                itsc : result.itsc
            });
        }
        
    })
    .catch( err => {
        res.status(500).json({
            error : true,
            message : "This account name is not linked to any ITSC"
        })
    })
});

module.exports = router;
