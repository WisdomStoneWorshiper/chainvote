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

const addCanidatePlaceholder = (name) => {
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
    const {name, key, accname, pkey} = req.body;
    Account.findOne({ name : name}, async (err, result) => {
        if(err || result == null) res.send("No account with the name")
        else{
            console.log(result)
            if(result.key === key){
                console.log("Valid confirmation")
                // Account creation sample TODO: Account name checking
                const transaction = await eosDriver.transact({
                    actions: [
                        // accountPlaceholder(accname, pkey),
                        addCanidatePlaceholder(accname)
                    ]
                   }, {
                    blocksBehind: 3,
                    expireSeconds: 30,
                   });
                //insert smart contract communication
                Account.findOneAndUpdate({name: name}, {created : true}).then(result => {
                    console.log(result);
                })
                res.send("Confirmation Successful")
            }
            else{
                res.send("Invalid key insert")
            }
        }
    } )

});

module.exports = router;