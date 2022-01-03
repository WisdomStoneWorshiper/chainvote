const express = require("express");
const Account = require("../../Helper functions/mongoose/accModel")
const router = express.Router();

//waypoints to add
/*
    1. only one, check if the username and key is correct
*/

router.post("/", async (req, res) => {
    /**
     * 1. Check if the username exists in the database
     * 2. Check if the code is the same
     */
    const {name, key} = req.body;
    Account.findOne({ name : name}, (err, result) => {
        if(err || result == null) res.send("No account with the name")
        else{
            console.log(result)
            if(result.key === key){
                console.log("Valid confirmation")
                //insert smart contract communication
                Account.deleteOne(result)
                res.send("Confirmation Successful")
            }
            else{
                res.send("Invalid key insert")
            }
        }
    } )

});

module.exports = router;