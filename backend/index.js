const express = require('express');
const cors = require('cors');

const mongoose = require("mongoose");
const Account = require("./Helper functions/mongoose/accModel");

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

// app.get("/", async (req, res) => {
//     const acc = new Account({name : "testasd", key : "test1"})
//     acc.save().then(() => {
//         res.status(200).send("success");
//     })
//     .catch(err => {
//         console.log(err)
//         res.status(200).send("fck")
//     })
// })

// app.get('/find', async (req, res) => {
//     await Account.find().then((result) => {
//         result.forEach(value => {
//             console.log(value._id)
//         })
//         res.send("success");
//     })
//     .catch(err => {
//         console.log(err)
//         res.send("failure");
//     })

// })

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


// app.listen(3000, () => {
//     console.log(`Listening at port ${process.env.SERVER_PORT}`);
// })



