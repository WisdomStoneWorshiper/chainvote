const express = require("express");
const router = express.Router();

const accModel = require("../../Helper functions/mongoose/accModel");
const eosDriver = require("../../Helper functions/eosDriver");
const { addVoterPlaceholder, delVoterPlaceholder } = require("../../Helper functions/eosPlaceholder");
const Account = require("../../Helper functions/mongoose/accModel");
require("dotenv").config();

<<<<<<< HEAD
// router.post("/addvoter", async (req, res) => {
//     const { itsc, campaignId } = req.body;

//     console.log("here");
//     const data = await accModel.findOne({itsc : itsc});
//     console.log("here2");
//     console.log(data);
//     if(!data || !data.accountName){
//         res.status(400).json({
//             error : true,
//             message : "Cannot find accountName",
//             itsc : itsc
//         })
//         return;
//     };
//     console.log("here3");

//     eosDriver.transact({
//         actions : [ 
//             addVoterPlaceholder(data.accountName, campaignId)
//         ]
//         },
//         {
//             blocksBehind: 3,
//             expireSeconds: 30,
//         }
//     )
//     .then( result => {
//         console.log(result);
//         res.json({
//             error : false
//         });
//     })
//     .catch( err => {
//         res.status(400).json({
//             error : true,
//             message : err.message,
//             itsc : itsc
//         })
//     })
//     console.log("here4");
=======
router.post("/addvoter", async (req, res) => {
    const { itsc = [], campaignId = 0, owner = "" } = req.body;
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234

    let ownerData = await Account.findOne( {itsc : owner});

    if(ownerData == null){
        res.status(400).json({
            error : true,
            message : "Cannot find ITSC user"
        });
        return;
    }

    let accountList = [];
    let errorAccount = [];

<<<<<<< HEAD
    for (let i = 0; i < itsc.length; i++) {
        try {
            const data = await accModel.findOne({ itsc: itsc[i] });
=======
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
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234

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
                    blocksBehind: 3,
                    expireSeconds: 30,
                }
            )
<<<<<<< HEAD
                .then(result => {
                    resolve()
                })
                .catch(err => {
                    errorVoter.push(delvoterList[i].itsc)
                    console.log(`User ${delvoterList[i].itsc} has faield`)
                    resolve();
                })
=======
            .then( result => {
                resolve()
            })
            .catch( err => {
                console.log(err)
                errorAccount.push(accountList[i].itsc)
                resolve();
            })
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234
        }))
    }

    await Promise.all(promiseArray)
        .then(() => {
            if (errorAccount.length >= 1) {
                res.status(400).json({
                    error: true,
                    failed: errorAccount
                })
            }
            else {
                res.json({
                    error: false
                })
            }
        })

});

<<<<<<< HEAD
// router.post("/delvoter", async (req, res) => {
//     const { itsc, campaignId } = req.body;
//     const data = await accModel.findOne({itsc : itsc});

//     if(!data || !data.accountName){
//         res.status(400).json({
//             error : true,
//             message : "Cannot find accountName",
//             itsc : itsc
//         })
//         return;
//     };
//     console.log(data);

//     const table = await eosDriver.rpc.get_table_rows({
//         json: true,               // Get the response as json
//         code: `${process.env.ACC_NAME}`,      // Contract that we target
//         scope: `${process.env.ACC_NAME}`,         // Account that owns the data
//         table: 'campaign',        // Table name,
//         lower_bound : campaignId,
//         // limit: 10,                // Maximum number of rows that we want to get
//         reverse: false,           // Optional: Get reversed data
//         show_payer: false          // Optional: Show ram payer
//     });
//     console.log(table);

//     var index = -1;
//     for (let i = 0; i < table["rows"].length; i++) {
//         console.log(table["rows"][i]["id"]);
//         if (table["rows"][i]["id"] == campaignId) {
//             for (let j = 0; j < table["rows"][i]["voter_list"].length; j++) {
//                 if (table["rows"][i]["voter_list"][j] == data.accountName) {
//                     index = j;
//                     break;
//                 }
//             }
//         }
//         if (index != -1) {
//             break;
//         }
//     }

//     if (index == -1) {
//         res.status(400).json({
//             error : true,
//             message : "Voter not in the voter list",
//             itsc : itsc
//         })
//         return;
//     }

//     eosDriver.transact({
//         actions : [delVoterPlaceholder(campaignId, index)]},
//         {
//             blocksBehind: 3,
//             expireSeconds: 30,
//         }
//     )
//     .then( result => {
//         res.json({
//             error : false
//         });
//     })
//     .catch( err => {
//         res.status(400).json({
//             error : true,
//             message : err.message,
//             itsc : itsc
//         })
//     })
=======
router.post("/delvoter", async (req, res) => {
    const { itsc = [], campaignId = 0, owner = "" } = req.body;
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234

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
<<<<<<< HEAD
        lower_bound: campaignId,
        limit: 3,                // Maximum number of rows that we want to get
=======
        lower_bound : campaignId,
        limit: 1,                // Maximum number of rows that we want to get
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234
        reverse: false,           // Optional: Get reversed data
        show_payer: false          // Optional: Show ram payer
    });

    let delvoterList = []
    let errorVoter = []

    for (let i = 0; i < table["rows"].length; i++) {
<<<<<<< HEAD
        console.log(table["rows"][i]["id"]);
        if (table["rows"][i]["id"] == campaignId) {
            console.log(`Campaign found at id ${campaignId}`)
            console.log(table["rows"][i]["voter_list"])
            for (let j = 0; j < itsc.length; j++) {
                try {
                    const data = await accModel.findOne({ itsc: itsc[j] });
                    const indexData = table["rows"][i]["voter_list"].indexOf(data.accountName);
                    console.log(`Currently searching for voter ${data.accountName}`)
                    if (indexData >= 0) {
                        console.log(`User ${data.accountName} index found at ${indexData}`)
=======
        if ((table["rows"][i]["id"] == campaignId) && (table["rows"][i]["owner"] == ownerData.accountName)) {
            //console.log(`Target owner ${table["rows"][i]["owner"]}`)
            //console.log(table["rows"][i]["voter_list"])
            for(let j = 0; j < itsc.length; j++){
                try{
                    const data = await accModel.findOne({itsc : itsc[j]});
                    const indexData = table["rows"][i]["voter_list"].indexOf(data.accountName);
                    if(indexData >= 0){
                        //console.log(`User ${data.accountName} index found at ${indexData}`)
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234
                        delvoterList.push({
                            acc: itsc[j],
                            index: indexData
                        })
                    }
                    else {
                        console.log("Not in array");
<<<<<<< HEAD
                        errorVoter.append(itsc);
                    }

                }
                catch (e) {

                    console.log(e)
                    console.log("Voter error");
                    errorVoter.append(itsc);

=======
                        errorVoter.push(itsc[j]);
                    }            

                }
                catch(e){
                    errorVoter.push(itsc[j]);
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234
                }
            }

        }
    }

    if(delvoterList.length <= 0){
        // console.log(ownerData)
        res.status(400).json({
            error : true,
            message : "Cannot find specified campaignId"
        });
        return;
    }

    let promiseArray = [] //this is quite stupid no?

<<<<<<< HEAD
    for (let i = 0; i < delvoterList.length; i++) {
        promiseArray.push(new Promise((resolve, reject) => {
            console.log(delvoterList[i]);
=======
    for(let i = 0; i < delvoterList.length; i++){
        promiseArray.push( new Promise( (resolve, reject) => {
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234
            eosDriver.transact({
                actions: [delVoterPlaceholder(campaignId, delvoterList[i].index)]
            },
                {
                    blocksBehind: 3,
                    expireSeconds: 30,
                }
            )
<<<<<<< HEAD
                .then(result => {
                    console.log(`User ${delvoterList[i]} has been deleted`);
                    resolve();
                })
                .catch(err => {
                    console.log(err)
                    errorVoter.push(delvoterList[i].acc)
                    console.log(`User ${delvoterList[i]} has faield`)
                    resolve();
                })
=======
            .then( result => {
                // console.log(`User ${delvoterList[i]} has been deleted`);
                resolve();
            })
            .catch( err => {
                errorVoter.push(delvoterList[i].acc)
                // console.log(`User ${delvoterList[i]} has faield`)
                resolve();
            })
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234
        }))
    }

    await Promise.all(promiseArray)
        .then(() => {
            if (errorVoter.length >= 1) {
                res.status(400).json({
                    error: true,
                    failed: errorVoter
                })
            }
            else {
                res.json({
                    error: false
                })
            }
        })

});

router.post("/login", async (req, res) => {
    const { itsc } = req.body;
    accModel.findOne({
<<<<<<< HEAD
        itsc: itsc,
=======
        itsc : itsc,
    })
    .then( result => {
        res.json({
            error : false,
            accountName : (result.accountName != itsc) ? result.accountName : null
        });
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234
    })
        .then(result => {
            res.json({
                error: false,
                accountName: result != null ? result.accountName : null
            });
        })
        .then(result => {
            res.json({
                error: false,
                accountName: result != null ? result.accountName : null
            });
        })
        .catch(err => {
            res.status(500).json({
                error: true,
                message: err.message
            })
        })
});

router.post("/getITSC", async (req, res) => {
    const { accountName } = req.body;
    accModel.findOne({
<<<<<<< HEAD
        accountName: accountName
=======
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
        
>>>>>>> c033f0cadb0dc758c452bd59a8ac20d674339234
    })
        .then(result => {
            res.json({
                error: false,
                itsc: result.itsc
            });
        })
        .catch(err => {
            res.status(500).json({
                error: true,
                message: "This account name is not linked to any ITSC"
            })
        })
});

module.exports = router;
