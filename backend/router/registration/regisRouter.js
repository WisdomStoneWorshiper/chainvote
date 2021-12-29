const express = require("express");
const router = express.Router();

//waypoints to add
/*
    1. Check if the registration name is created
    2. Register the name and create a randomized code key
*/

router.get("/check/:userId", async (req, res) => {
    //Insert username checking function
    //Return the result if it is valid
    console.log(`Current ID check ${req.params.userId}`)
    res.send("check userID route")
});

router.post("/register", async (req, res) => {
    res.send("register route")
});

module.exports = router;