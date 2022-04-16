const express = require('express');
const cors = require('cors');

const mongoose = require("mongoose");
const Account = require("./Helper functions/mongoose/accModel");

const registration = require("./router/registration/regisRouter");
const account = require('./router/account/accountRouter')
const contract = require("./router/contract/contractRouter")
const test = require('./router/testRouter');

require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
    next();
})

app.get("/", (req, res) => {
    res.json({ name : "yes" });
})

app.use("/registration", registration);
app.use("/contract", contract);
app.use("/account", account);
app.use("/test", test);

mongoose.connect(process.env.URI, {useNewUrlParser: true, useUnifiedTopology : true})
    .then(() => {
        app.listen(process.env.SERVER_PORT, ()=> {
            console.log(`Listening at port ${process.env.SERVER_PORT}`);
            app.emit("serverStart");
        })
    })
    .catch((err) => {
        console.log(err);
    }
)

module.exports = app;



