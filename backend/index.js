const express = require('express');
const cors = require('cors');

const mongoose = require("mongoose");
const Account = require("./Helper functions/mongoose/accModel");

const registration = require("./router/registration/regisRouter");
const confirmation = require("./router/confirmation/confirmRouter")
const account = require('./router/account/accountRouter')

require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {

    console.log("enter server");
    next();
})

app.use("/registration", registration);
app.use("/confirmation", confirmation);
app.use("/account", account);

mongoose.connect(process.env.URI, {useNewUrlParser: true, useUnifiedTopology : true})
    .then(() => {
        app.listen(process.env.SERVER_PORT, ()=> {
            console.log(`Listening at port ${process.env.SERVER_PORT}`);
        })
    })
    .catch((err) => {
        console.log(err);
    }
)



