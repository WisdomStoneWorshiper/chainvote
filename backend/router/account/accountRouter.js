const express = require('express');
const eosDriver = require('../../Helper functions/eosDriver')
const {ecc} = require("eosjs/dist/eosjs-ecc-migration")
const Account = require("../../Helper functions/mongoose/accModel")
require('dotenv').config();

const router = express.Router();

const accountPlaceholder = (name, publicKey) => {
    return (
        {
            account: 'eosio',
            name: `newaccount`, // new account name
            authorization: [{
              actor: `${process.env.ACC_NAME}`, // which account generates it
              permission: 'active',
            }],
            data: {
              creator: `${process.env.ACC_NAME}`,
              name: `${name}`,
              owner: {
                threshold: 1,
                keys: [{
                  key: `${publicKey}`,
                  weight: 1
                }],
                accounts: [],
                waits: []
              },
              active: {
                threshold: 1,
                keys: [{
                  key: `${publicKey}`,
                  weight: 1
                }],
                accounts: [],
                waits: []
              },
            }
          }
    );
}

const addVoterPlaceholder = (name) => {
    return         {
        account: `${process.env.ACC_NAME}`,
        name: `createvoter`, // new account name
        authorization: [{
          actor: `${process.env.ACC_NAME}`, // which account generates it
          permission: 'active',
        }],
        data: {
            new_voter: `${name}`
        }
      }
}

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

router.get("/create", async (req, res) => {
    const {itsc, key, accname, pkey} = req.body
    Account.findOne({itsc : itsc}, async (err, result) => {
        if(err || result.length == 0){
            res.json({
                error : true,
                message : "Invalid itsc"
            });
            return;
        }
        else{
            if(result.key !== key || result.accountName){
                res.json({
                    error: true,
                    message : "Invalid confirmation key or Account has been created"
                });
                return;
            }
            //begin acc creation
            const transaction  = await eosDriver.transact({
                actions: [
                    accountPlaceholder(accname, pkey),
                    addVoterPlaceholder(accname)
                ]
               }, {
                blocksBehind: 3,
                expireSeconds: 30,
               })
            .then(result => {
                console.log(result);
                Account.findOneAndUpdate({itsc: itsc}, {publicKey : pkey, accountName : accname})
                .then(result => res.json({
                    error: false,
                }))
                .catch(err => {
                    res.json({
                        error: true,
                        message: "Itsc account cannot be updated"
                    })
                })
            })
            .catch(err => {
                console.log(err)
                res.json({
                    error: true,
                    message: err.message
                })
            })
        }
    });
})


module.exports = router

