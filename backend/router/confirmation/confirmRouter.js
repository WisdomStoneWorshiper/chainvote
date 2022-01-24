const express = require("express");
const Account = require("../../Helper functions/mongoose/accModel")
const {addVoterPlaceholder} = require("../../Helper functions/eosPlaceholder")
const eosDriver = require("../../Helper functions/eosDriver")
const router = express.Router();

require('dotenv').config();

router.post("/", async (req, res) => {
    console.log("Entering confirmation")
    console.log(req.body)

    const {itsc, key, accname, pkey} = req.body;
    Account.findOne({ itsc : itsc}, async (err, result) => {
        if(err || result.length == 0) {
          res.json({
            error : true,
            message : "Invalid itsc"
          });
          return;
        }
        else{
            console.log(result)
            if(result.key === key && !result.publicKey){
                console.log("Valid confirmation")
                // Account creation sample TODO: Account name checking
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
                       error : true,
                       message : err.message
                     })
                   });
                
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