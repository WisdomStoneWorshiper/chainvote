const getAccount = require("./accountParser")
const eosDriver = require("../../Helper functions/eosDriver")
const {
    createVoterPlaceholder,
} = require("../../Helper functions/eosPlaceholder")
const getRandomString = require("../../Helper functions/randomStringGeneration")
const { Api, JsonRpc } = require('eosjs');
const { JsSignatureProvider } = require('eosjs/dist/eosjs-jssig');  // development only
const fetch = require('node-fetch'); //node only
const { TextDecoder, TextEncoder } = require('util'); //node only

require('dotenv').config()


function sleep(ms) {
    return new Promise((resolve) => {
      setTimeout(resolve, ms);
    });
}

const main = async () => {
    // Collect all account
    console.log("=== PERFORMANCE TESTING STARTS ===")
    const data = getAccount("./test/performance/username.txt")
    let account = []
    let failedAccount = []

    let nextKey = ""
    // Get the valid voters table and add if does not exist
    while(true){
        let accTable = await eosDriver.rpc.get_table_rows({
            json: true,               // Get the response as json
            code: process.env.ACC_NAME,      // Contract that we target
            scope: process.env.ACC_NAME,         // Account that owns the data
            lower_bound : nextKey,
            table: 'voter',        // Table name
            reverse: false,           // Optional: Get reversed data
            show_payer: false          // Optional: Show ram payer
          })
        accTable["rows"].forEach(value => account.push(value.voter));
        if(accTable.more){
            nextKey = accTable.next_key;
        }
        else{
            break;
        }
    }

    data.forEach(async acc => {
        if(account.find(name => name == acc.accname) == undefined){
            await eosDriver.transact({
                actions: [
                    createVoterPlaceholder(acc.accname)
                ]
               },
                {
                blocksBehind: 3,
                expireSeconds: 30,
               }
            )
            .catch(err => {
            // console.log(err.message);
            // console.log(`Failed Account ${acc.accname}`);
            failedAccount.push(acc);
        });
        }
    })

    console.log("- Added Accounts to contract")

    // Generate Campaign
    const campaignName = getRandomString(10);
    const HALF_MINUTE = new Date(1000*30)
    const MINUTE_5 = new Date(1000*60*5)
    let currentDate = new Date();
    let startTime = new Date( currentDate.getTime() + HALF_MINUTE.getTime());
    let endTime = new Date( currentDate.getTime() + 2 * MINUTE_5.getTime());
    await eosDriver.transact({
        actions: [
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

    // find campaign created
    let campaignId = -1;
    nextKey = "";
    while(true){
        let campaignTable = await eosDriver.rpc.get_table_rows({
            json: true,               // Get the response as json
            code: process.env.ACC_NAME,      // Contract that we target
            scope: process.env.ACC_NAME,         // Account that owns the data
            lower_bound : nextKey,
            table: 'campaign',        // Table name
            reverse: false,           // Optional: Get reversed data
            show_payer: false          // Optional: Show ram payer
          })
        campaignTable["rows"].forEach(value => {
            if(value.campaign_name === campaignName){
                campaignId = value.id;
            }
        });
        if(campaignId !== -1){
            break;
        }
        else if(campaignTable.more){
            nextKey = campaignTable.next_key;
        }
        else{
            console.log("FAILED TO FIND CAMPAIGN");
            exit(1);
        }
    }

    // add a choice
    await eosDriver.transact({
        actions: [
            {
                account: process.env.ACC_NAME,
                name: 'addchoice',
                authorization: [{
                  actor: process.env.ACC_NAME,
                  permission: 'active',
                }],
                data: {
                  owner : process.env.ACC_NAME,
                  campaign_id : campaignId,
                  new_choice : "test"
                },
              }
        ]
       },
        {
        blocksBehind: 3,
        expireSeconds: 30,
       }
    )

    // Add all users
    data.forEach(async acc => {
        await eosDriver.transact({
            actions: [
                {
                    account: process.env.ACC_NAME,
                    name: 'addvoter',
                    authorization: [{
                      actor: process.env.ACC_NAME,
                      permission: 'active',
                    }],
                    data: {
                      campaign_id : campaignId,
                      voter : acc.accname
                    },
                  }
            ]
           },
            {
            blocksBehind: 3,
            expireSeconds: 30,
           }
        )
        .catch(err => {
        console.log(err.message);
        console.log(`Failed Account ${acc.accname}`);
        failedAccount.push(acc);
    });
    })

    console.log(`- Set up the campaign -> ${campaignName}`)

    //checking time 
    let currentTime = new Date();
    console.log(`Delaying for ${startTime.getTime() - currentTime.getTime() + 1000} before voting`)
    await sleep(startTime.getTime() - currentTime.getTime() + 2000);

    console.log(`Starting to vote now at ${new Date()}`)

    //time to vote
    let promisedVoter = []

    data.forEach( acc => {
        promisedVoter.push(
            new Promise( async (resolve, reject) => {
                let voteTime = new Date();
                let selfDriver = new Api(
                    { 
                        rpc : eosDriver.rpc,
                        signatureProvider : new JsSignatureProvider([acc.key]), 
                        textDecoder: new TextDecoder(), 
                        textEncoder: new TextEncoder() 
                    });


                await selfDriver.transact({
                    actions: [
                        {
                            account: process.env.ACC_NAME,
                            name: 'vote',
                            authorization: [{
                              actor: acc.accname,
                              permission: 'active',
                            }],
                            data: {
                              campaign_id : campaignId,
                              voter : acc.accname,
                              choice_idx : 0
                            },
                          }
                    ]
                   },
                    {
                    blocksBehind: 3,
                    expireSeconds: 30,
                   }
                )
                .then( () => {
                    resolve({
                        success : true,
                        username : acc.accname,
                        time : new Date() - voteTime
                    })
                })
                .catch(err => {
                    resolve({
                        success : false,
                        username : acc.accname,
                        key : acc.key,
                        error : err
                    })
                });
            })
        )
    })

    Promise.all(promisedVoter)
    .then( result => {
        let totalAccount = 0;
        let avgTime = 0;
        let failedAccount = [];

        result.forEach(value => {
            if(value.success){
                totalAccount++;
                avgTime = (avgTime * (totalAccount - 1)+ value.time) / (totalAccount)
            }
            else{
                failedAccount.push(value)
            }
        })
        console.log(`Num of Acc : ${totalAccount} Time : ${avgTime}`)
    })



}

main();
