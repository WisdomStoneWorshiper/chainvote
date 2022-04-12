let Account = require("../../Helper functions/mongoose/accModel")
let eosDriver = require("../../Helper functions/eosDriver")
let {accountPlaceholder} = require("../../Helper functions/eosPlaceholder")
let getRandomString = require("../../Helper functions/randomStringGeneration")

let chai = require("chai")
let chaiHttp = require('chai-http')
const { assert } = require("chai")
let should = chai.should()

const main = async () => {

    const accountName = getRandomString(7);
    const keyConf = getRandomString(5);
    const fixedName = getRandomString(12);
    let keypair = {};

    const DAY_OFFSET = new Date(1000 * 3600 * 24);
    let currentDate = new Date();
    let startTime = new Date( currentDate.getTime() + DAY_OFFSET.getTime());
    let endTime = new Date( currentDate.getTime() + 2 * DAY_OFFSET.getTime());

    let campaignId = -1;
    const campaignName = getRandomString(8);


    await eosDriver.transact({
        actions : [
            {
                account: process.env.ACC_NAME,
                name: 'createcamp',
                authorization: [{
                  actor: process.env.ACC_NAME,
                  permission: 'active',
                }],
                data: {
                    owner : process.env.ACC_NAME,
                    campaign_name : campaignName,
                    start_time_string : startTime.toISOString(),
                    end_time_string : endTime.toISOString()
                },
              }
        ]
        },
        {
            blocksBehind: 3,
            expireSeconds: 30,
        }
    )
    .then(res => console.log(res))
    .catch(err => { assert.fail(err)})
    
    let currentBound = "";
    do {
        const table = await eosDriver.rpc.get_table_rows({
            json: true,               // Get the response as json
            code: `${process.env.ACC_NAME}`,      // Contract that we target
            scope: `${process.env.ACC_NAME}`,         // Account that owns the data
            table: 'campaign',        // Table name,
            lower_bound : currentBound,
            reverse: false,           // Optional: Get reversed data
            show_payer: false          // Optional: Show ram payer
        });

        for (let i = 0; i < table["rows"].length; i++) {
            if (table["rows"][i]["campaign_name"] == campaignName) {
                console.log(`Found campaign id at ${table["rows"][i]}`)
                campaignId = table["rows"][i]["id"]
            }
        }

        if(table["more"]){
            currentBound = table["next_key"]
        }
        else break;

    } while(campaignId == -1)

    if(campaignId == -1) {console.log("bullshit")}
}

main()