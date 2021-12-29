const express = require("express");
const router = express.Router();

//waypoints to add
/*
    1. only one, check if the username and key is correct
*/

router.post("/validate", async (req, res) => {
    /**
     * 1. Check if the username exists in the database
     * 2. Check if the code is the same
     */
    res.send("confirm validate route")
});

module.exports = router;