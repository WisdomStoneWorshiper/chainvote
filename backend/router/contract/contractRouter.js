const express = require("express");
const router = express.Router();

const accModel = require("../../Helper functions/mongoose/accModel");
const eosDriver = require("../../Helper functions/eosDriver");
const { addVoterPlaceholder } = require("../../Helper functions/eosPlaceholder")
require("dotenv").config();

router.post("/addvoter", async (req, res) => {
    const { itsc, campaignId } = req.body;
    const data = await accModel
        .findOne({itsc : itsc})
        .select("accountName")
        .then(result => res.json(result));
    
    if(!data || !data.accountName){
        res.status(400).json({
            error : true,
            message : "Cannot find accountName"
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
            error : false,
            message : err.message
        })
    })

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

module.exports = router;