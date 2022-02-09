const { loadConfig, Blockchain } = require("@klevoya/hydra");
const assert = require("assert");
const { isTypedArray } = require("util/types");
require("dotenv").config();

const config = loadConfig("hydra.yml");

const DAY_OFFSET = new Date(1000 * 3600 * 24);

let currentDate = new Date();
let startTime = new Date( currentDate.getTime() + DAY_OFFSET.getTime());
let endTime = new Date( currentDate.getTime() + 2 * DAY_OFFSET.getTime());
let prevTime = new Date( currentDate.getTime() - 2 * DAY_OFFSET.getTime());

describe("votingplat", () => {
  let blockchain = new Blockchain(config);
  let contractAcc = blockchain.createAccount(`votingplat`);

  let userAccount1 = blockchain.createAccount("useracc1");
  let userAccount2 = blockchain.createAccount("useracc2");

  beforeAll(async () => {
    contractAcc.setContract(blockchain.contractTemplates[`votingplat`]);
    contractAcc.updateAuth(`active`, `owner`, {
      accounts: [
        {
          permission: {
            actor: contractAcc.accountName,
            permission: `eosio.code`
          },
          weight: 1
        }
      ]
    });
  });

  beforeEach(async () => {
    contractAcc.resetTables();
  });

  describe("createvoter", function(){

    it("Should create new voter", async function(){
      expect.assertions(1);

      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
      .catch(err => console.log(err.message));

      expect(
        contractAcc.getTableRowsScoped("voter")["votingplat"])
      .toEqual(
        [
          {
            voter: 'useracc1',
            owned_campaigns: [],
            votable_campaigns: [],
            is_active: false
          }
        ]
      );
    });

    it('Should not have duplicateed voter', async function(){
      expect.assertions(2);

      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
      
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
      .catch( err => {
        expect(
          err.message
          .indexOf(
            "assertion failure with message: voter exist"
            ) >= 0
          ).toEqual(true);
        expect(
          contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual(
          [
            {
              voter: 'useracc1',
              owned_campaigns: [],
              votable_campaigns: [],
              is_active: false
            }
          ]
        );
      })
    })

    it('Should not create voter without admin account', async function(){
      expect.assertions(2);
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch( err => {
        expect(
          err.message
          .indexOf(
            "missing authority of votingplat"
            ) >= 0
          ).toEqual(true);
        expect(contractAcc.getTableRowsScoped("voter")["votingplat"])
        .toEqual(undefined) //because the table has not been generated
      })
    });
  })

  describe("createcamp", function(){

    beforeEach(async () => {
      await contractAcc.contract.createvoter({
        new_voter : userAccount1.accountName
      })
    })

    it("Should create a campaign", async function(){
      expect.assertions(1);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .then( res => {
        expect(contractAcc.getTableRowsScoped("campaign")["votingplat"])
        .toEqual([{
          id : "0",
          campaign_name : "testcamp",
          owner : userAccount1.accountName,
          choice_list : [],
          start_time : startTime.toISOString().split(".")[0] + ".000",
          end_time : endTime.toISOString().split(".")[0] + ".000"
        }])
      })
    });

    it("Should not create a campaign without auth", async function(){
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount2.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "You are not authorized to use this account"
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual(undefined); //since the table isnt generated yet
      });
    });

    it("Should not create duplicate campaign", async function(){
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])

      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : startTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "campaign exists"
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual([{
          id : "0",
          campaign_name : "testcamp",
          owner : userAccount1.accountName,
          choice_list : [],
          start_time : startTime.toISOString().split(".")[0] + ".000",
          end_time : endTime.toISOString().split(".")[0] + ".000"
        }]); //since the table isnt generated yet
      });
    });

    it("Should not create a campaign with later start time", async function(){ //fix this tmrw
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        end_time : startTime.toISOString().split(".")[0],
        start_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "Invalid timing: Start is later than End "
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual(undefined); //since the table isnt generated yet
      });
    });

    it("Should not create a campaign with startTime > now", async function(){ //fix this 
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount1.accountName,
        campaign_name : "testcamp",
        start_time : prevTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount1.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "Invalid timing: Campaign must start before the current time"
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual(undefined); //since the table isnt generated yet
      });
    });

    it("Should not create a campaign with no owner", async function(){
      expect.assertions(2);
      await contractAcc.contract.createcamp({
        owner : userAccount2.accountName,
        campaign_name : "testcamp",
        start_time : prevTime.toISOString().split(".")[0],
        end_time : endTime.toISOString().split(".")[0]
      }, [{
        actor : userAccount2.accountName,
        permission : "active"
      }])
      .catch(err => {
        expect(
          err.message
          .indexOf(
            "owner not exist"
            ) >= 0
          )
        .toEqual(true);

        expect(
          contractAcc.getTableRowsScoped("campaign")["votingplat"]
        )
        .toEqual(undefined); //since the table isnt generated yet
      });
    });

    // describe("addchoice", function(){
    //   beforeEach(async ()=> {
    //     await contractAcc.contract.createvoter({
    //       new_voter : userAccount1.accountName
    //     })
    //     await contractAcc.contract.createcamp({
    //       owner : userAccount1.accountName,
    //       campaign_name : "testcamp",
    //       start_time : startTime.toISOString().split(".")[0],
    //       end_time : endTime.toISOString().split(".")[0]
    //     }, [{
    //       actor : userAccount1.accountName,
    //       permission : "active"
    //     }])

    //   })

    //   it("should add choice1 on c")
    // });

  });
});
