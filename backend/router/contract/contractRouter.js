const express = require("express");
const router = express.Router();

const accModel = require("../../Helper functions/mongoose/accModel");
const eosDriver = require("../../Helper functions/eosDriver");
const { addVoterPlaceholder, delVoterPlaceholder } = require("../../Helper functions/eosPlaceholder")
require("dotenv").config();

router.post("/addvoter", async (req, res) => {
    const { itsc, campaignId } = req.body;
    console.log("here");
    const data = await accModel.findOne({itsc : itsc});
    console.log("here2");
    console.log(data);
    if(!data || !data.accountName){
        res.status(400).json({
            error : true,
            message : "Cannot find accountName",
            itsc : itsc
        })
        return;
    };
    console.log("here3");

    eosDriver.transact({
        actions : [ 
            addVoterPlaceholder(data.accountName, campaignId)
        ]
        },
        {
            blocksBehind: 3,
            expireSeconds: 30,
        }
    )
    .then( result => {
        console.log(result);
        res.json({
            error : false
        });
    })
    .catch( err => {
        res.status(400).json({
            error : true,
            message : err.message,
            itsc : itsc
        })
    })
    console.log("here4");

});

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

// });

router.post("/delvoter", async (req, res) => {
    const { itsc, campaignId } = req.body;

    const table = await eosDriver.rpc.get_table_rows({
        json: true,               // Get the response as json
        code: `${process.env.ACC_NAME}`,      // Contract that we target
        scope: `${process.env.ACC_NAME}`,         // Account that owns the data
        table: 'campaign',        // Table name,
        lower_bound : campaignId,
        // limit: 10,                // Maximum number of rows that we want to get
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

    for(let i = 0; i < delvoterList.length; i++){
        await eosDriver.transact({
            actions : [delVoterPlaceholder(campaignId, delvoterList[i].indexData)]},
            {
                blocksBehind: 3,
                expireSeconds: 30,
            }
        )
        .then( result => console.log(result))
        .catch( err => {
            errorVoter.push(delvoterList[i]..acc)
        })
    }

    res.json({
        error : false,
        data : errorVoter
    })

});



router.post("/login", async (req, res) => {
    const { itsc, publicKey } = req.body;
    accModel.findOne({
        itsc : itsc,
    })
    .then( result => {
        res.json({
            error : false,
            accountName : result != null ? result.accountName : null
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
        res.json({
            error : false,
            itsc : result.itsc
        });
    })
    .catch( err => {
        res.status(500).json({
            error : true,
            message : "This account name is not linked to any ITSC"
        })
    })
});

// router.post("/checkPubKey", async (req, res) => {
//     const { itsc , publicKey } = req.body;
//     accModel.findOne({
//         itsc : itsc
//     })
//     .then( result => {
//         if (result.publicKey == publicKey) {
//             res.json({
//                 error : false,
//                 match : true
//             })
//         } else {
//             res.json({
//                 error : false,
//                 match : false
//             });
//         }
//     })
//     .catch( err => {
//         res.status(500).json({
//             error : true,
//             message : "Invalid ITSC"
//         })
//     })
// });

module.exports = router;