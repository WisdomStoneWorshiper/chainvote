const express = require('express');
const cors = require('cors');

const registration = require("./router/registration/regisRouter");
const confirmation = require("./router/confirmation/confirmRouter")

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


app.listen(3000, () => {
    console.log(`Listening at port ${process.env.SERVER_PORT}`);
})



