const express = require('express');
const eosDriver = require('../../Helper functions/eosDriver')
const generateKeyPair = require("../../Helper functions/keyPairGeneration")
const {
    createVoterPlaceholder, 
    accountPlaceholder, 
    eosNameValidation,
} = require("../../Helper functions/eosPlaceholder")
const Account = require("../../Helper functions/mongoose/accModel")
require('dotenv').config();

const router = express.Router();

// router.get('/pair', async (req, res) => {
//     const temp = await generateKeyPair();
//     res.json(temp);
// })

router.post("/create", async (req, res) => {
    const {itsc, key, accname, pkey} = req.body
    Account.findOne({itsc : itsc}, async (err, result) => {
        if(err || result === null){
            res.status(500).json({
                error : true,
                message : "Invalid itsc"
            });
            return;
        }
        else{
            if(result.created){
                res.status(500).json({
                    error: true,
                    message : "Account has already been created"
                });
                return;
            }
            if(result.key !== key){
                res.status(500).json({
                    error: true,
                    message : "Invalid confirmation key"
                })
                return;
            }
            if(!eosNameValidation(accname)){
                res.status(500).json({
                    error: true,
                    message : "Invalid account name"
                })
                return;
            }
            const transaction  = await eosDriver.transact({
                actions: [
                    accountPlaceholder(accname, pkey)
                ]
               }, {
                useLastIrreversible : true,
                expireSeconds: 30,
               })
            .then(result => {
                Account.findOneAndUpdate({itsc: itsc}, {created: true})
                .then(result => res.json({
                    error: false,
                }))
                .catch(err => {
                    res.status(500).json({
                        error: true,
                        message: "Itsc account cannot be updated"
                    })
                })
            })
            .catch(err => {
                res.status(500).json({
                    error: true,
                    message: err.message
                })
            })
        }
    });
})

router.post("/confirm", async (req, res) => {

    const {itsc, key, accname} = req.body;
    Account.findOne({ itsc : itsc}, async (err, result) => {
        if(err || result === null) {
          res.status(500).json({
            error : true,
            message : "Invalid itsc"
          });
          return;
        }
        else{
            if(result.key !== key){
                res.status(500).json({
                    error: true,
                    message : "Invalid confirmation key"
                })
                return;
            }
            if(!eosNameValidation(accname)){
                res.status(500).json({
                    error: true,
                    message : "Invalid account name"
                })
                return;
            }
            const transaction = await eosDriver.transact({
                actions: [
                    createVoterPlaceholder(accname)
                ]
                }, {
                useLastIrreversible : true,
                expireSeconds: 30,
                })
            .then(result => {
                Account.findOneAndUpdate({itsc: itsc}, {accountName : accname})
                .then(result => {
                    res.json({
                    error : false
                    });
                })
                .catch(err => {
                console.log(err)
                res.status(500).json({
                    error: true,
                    message: "Itsc account cannot be updated "
                })
                })
            })
            .catch(err => {
                res.status(500).json({
                error : true,
                message : err.message
                })
            });
                
        }
    })

});

module.exports = router

