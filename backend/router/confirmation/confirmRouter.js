const express = require("express");
const Account = require("../../Helper functions/mongoose/accModel")
const eosDriver = require("../../Helper functions/eosDriver")
const router = express.Router();

const accountPlaceholder = (name, publicKey) => {
    return (
        {
            account: 'eosio',
            name: `newaccount`, // new account name
            authorization: [{
              actor: 'main', // which account generates it
              permission: 'active',
            }],
            data: {
              creator: 'main',
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
        account: 'main',
        name: `addvoter`, // new account name
        authorization: [{
          actor: 'main', // which account generates it
          permission: 'active',
        }],
        data: {
            new_voter: `${name}`
        }
      }
}




router.post("/", async (req, res) => {
    /**
     * 1. Check if the username exists in the database
     * 2. Check if the code is the same
     */
    /**
     * Body schema
     * 1. name : itsc account
     * 2. key : email confirmation 
     * 3. accname : account name
     * 4. pkey : public key 
     */
    console.log("Entering confirmation")
    console.log(req.body)

    const {itsc, key, accname, pkey} = req.body;
    Account.findOne({ itsc : itsc}, async (err, result) => {
        if(err || result.length == 0) {
          res.json({
            error : true,
            message : "Invalid itsc"
          });
        }
        else{
            console.log(result)
            if(result.key === key && !result.publicKey){
                console.log("Valid confirmation")
                // Account creation sample TODO: Account name checking
                const transaction = await eosDriver.transact({
                    actions: [
                        accountPlaceholder(accname, pkey),
                        addVoterPlaceholder(accname)
                    ]
                   }, {
                    blocksBehind: 3,
                    expireSeconds: 30,
                   })
                   .then(result => {
                    Account.findOneAndUpdate({itsc: itsc}, {publicKey : pkey, accountName : accname})
                    .then(result => {
                      console.log(result);
                      res.json({
                        error : false
                      });
                    })
                    .catch(err => {
                    res.json({
                      error: true,
                      message: err.message
                    })
                  })
                })
                   .catch(err => {
                     console.log("Detected error")
                     console.log(err.message)
                     res.json({
                       "fuck" : "you"
                     })
                   })
                
            }
            else{
              res.json({
                error : true,
                message : "Invalid key or public key exists"
              });
            }
        }
    })

});

module.exports = router;