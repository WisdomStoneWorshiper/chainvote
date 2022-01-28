const express = require('express');
const eosDriver = require('../../Helper functions/eosDriver')
const {ecc} = require("eosjs/dist/eosjs-ecc-migration")
const {addVoterPlaceholder, accountPlaceholder} = require("../../Helper functions/eosPlaceholder")
const Account = require("../../Helper functions/mongoose/accModel")
require('dotenv').config();

const router = express.Router();

const generateKeyPair = async () => {
    const tempPrivate = await ecc.randomKey(undefined,{secureEnv : true});
    return {
        private : `${tempPrivate}`,
        public : `${ecc.privateToPublic(tempPrivate)}`
    };
}


router.get('/pair', async (req, res) => {
    const temp = await generateKeyPair();
    res.json(temp);
})

router.post("/create", async (req, res) => {
    const {itsc, key, accname, pkey} = req.body
    Account.findOne({itsc : itsc}, async (err, result) => {
        if(result == null || result.length == 0){
            // console.log("dead1")
            res.status(500).json({
                error : true,
                message : "Invalid itsc"
            });
            return;
        }
        else{
            if(result.created){
                // console.log("dead2")
                res.status(500).json({
                    error: true,
                    message : "Account has already been created"
                });
                return;
            }
            if(result.key !== key){
                // console.log("dead3")
                res.status(500).json({
                    error: true,
                    message : "Invalid confirmation key"
                })
                return;
            }
            //begin acc creation
            const transaction  = await eosDriver.transact({
                actions: [
                    accountPlaceholder(accname, pkey)
                ]
               }, {
                blocksBehind: 3,
                expireSeconds: 30,
               })
            .then(result => {
                // console.log(result);
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
                // console.log(err)
                res.status(500).json({
                    error: true,
                    message: err.message
                })
            })
        }
    });
})

router.post("/confirm", async (req, res) => {
    // console.log("Entering confirmation")
    // console.log(req.body)

    const {itsc, key, accname, pkey} = req.body;
    Account.findOne({ itsc : itsc}, async (err, result) => {
        if(err || result == undefined) {
          res.status(500).json({
            error : true,
            message : "Invalid itsc"
          });
          return;
        }
        else{
            // console.log(result)
            if(result.key === key && !result.publicKey){
                // console.log("Valid confirmation")
                // Account creation sample TODO: Account name checking
                console.log(addVoterPlaceholder(accname))
                const transaction = await eosDriver.transact({
                    actions: [
                        addVoterPlaceholder(accname)
                    ]
                   }, {
                    blocksBehind: 3,
                    expireSeconds: 30,
                   })
                   .then(result => {
                    Account.findOneAndUpdate({itsc: itsc}, {publicKey : pkey, accountName : accname})
                    .then(result => {
                    //   console.log(result);
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
                    //  console.log("Detected error")
                    //  console.log(err.message)
                     res.status(500).json({
                       error : true,
                       message : err.message
                     })
                   });
                
            }
            else{
              res.status(500).json({
                error : true,
                message : result.publicKey ? "Account has been linked" : "Invalid confirmation key"
              });
            }
        }
    })

});

module.exports = router

