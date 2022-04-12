const express = require("express");
const router = express.Router();
const sgMail = require('../../Helper functions/emailDriver')
const getRandomString = require("../../Helper functions/randomStringGeneration")
const Account = require("../../Helper functions/mongoose/accModel")

//waypoints to add
/*
    1. Check if the registration name is created
    2. Register the name and create a randomized code key
*/

router.post("/", async (req, res) => {
    console.log("enter")
    const {itsc} = req.body;
    const result = await Account.find({itsc : itsc})
    .catch(err => {
        res.json({
            error : true,
            message : "Unexpected error searching itsc" 
        });
        return;
    })
    if(result.length != 0){ //acc found
        const random_str = getRandomString(5);
        Account.findOneAndUpdate({itsc : itsc}, {key : random_str})
        .then( result => {
            sgMail(`${itsc}@connect.ust.hk`, "Email confirmation", `Your confirmation key is ${random_str}`)//TODO handle mail limit?
            res.json({
                error : false
            })
        })
        .catch(err => {
            console.log(err)
            res.status(500).json({
                error : true,
                message : "Failed to update and send email"
            })
        })
    }
    else{ // acc not found
        res.status(500).json({
            error : true,
            message : "Invalid itsc"
        });
    }

});

module.exports = router;
