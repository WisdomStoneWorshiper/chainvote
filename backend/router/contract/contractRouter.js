const express = require("express");
const router = express.Router();

const accModel = require("../../Helper functions/mongoose/accModel");
const eosDriver = require("../../Helper functions/eosDriver");
const { addVoterPlaceholder } = require("../../Helper functions/eosPlaceholder")
require("dotenv").config();

router.post("/addvoter", async (req, res) => {
    const { itsc_list, campaignId } = req.body;
    for (let i = 0; i < itsc_list; i++) {
        const data = await accModel
            .findOne({itsc : itsc_list[i]})
            .select("accountName")
            .then(result => res.json(result));
        
        if(!data || !data.accountName){
            res.status(400).json({
                error : true,
                message : "Cannot find accountName",
                itsc : itsc_list[i]
            })
        };

        eosDriver.transact({
            actions : [addVoterPlaceholder(accName, campaignId)]},
            {
                blocksBehind: 3,
                expireSeconds: 30,
            }
        )
        .then( result => {
            res.json({
                error : false
            });
        })
        .catch( err => {
            res.status(400).json({
                error : true,
                message : err.message,
                itsc : itsc_list[i]
            })
        })
    }

});



router.post("/login", async (req, res) => {
    const { itsc, publicKey } = req.body;
    accModel.findOne({
        itsc : itsc,
        publicKey : publicKey
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

router.post("/checkPubKey", async (req, res) => {
    const { itsc , publicKey } = req.body;
    accModel.findOne({
        itsc : itsc
    })
    .then( result => {
        if (result.publicKey == publicKey) {
            res.json({
                error : false,
                match : true
            })
        } else {
            res.json({
                error : false,
                match : false
            });
        }
    })
    .catch( err => {
        res.status(500).json({
            error : true,
            message : "Invalid ITSC"
        })
    })
});

module.exports = router;