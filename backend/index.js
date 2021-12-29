const express = require('express');
const cors = require('cors');

const registration = require("./router/registration/regisRouter");
const confirmation = require("./router/confirmation/confirmRouter")

require('dotenv').config();

const app = express();

app.use(cors);
app.use(express.json());

app.use("/registration", registration);
app.use("/confirmation", confirmation);

app.listen(process.env.SERVER_PORT, () => {
    console.log(`Listening at port ${process.env.SERVER_PORT}`);
})



