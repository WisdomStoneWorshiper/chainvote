const  ecc = require('eosjs-ecc')

const accountPlaceholder = (name, publicKey) => {
    return (
        {
            account: 'eosio',
            name: `newaccount`, // new account name
            authorization: [{
              actor: `${process.env.ACC_NAME}`, // which account generates it
              permission: 'active',
            }],
            data: {
              creator: `${process.env.ACC_NAME}`,
              name: `${name}`,
              owner: {
                threshold: 1,
                keys: [{
                  key: `${publicKey}`,
                  weight: 1
                }],
                accounts: [],
                waits: []
              },
              active: {
                threshold: 1,
                keys: [{
                  key: `${publicKey}`,
                  weight: 1
                }],
                accounts: [],
                waits: []
              },
            }
          }
    );
}

const createVoterPlaceholder = (name) => {
    return         {
        account: `${process.env.ACC_NAME}`,
        name: `createvoter`, // new account name
        authorization: [{
          actor: `${process.env.ACC_NAME}`, // which account generates it
          permission: 'active',
        }],
        data: {
            new_voter: `${name}`
        }
      }
}

const addVoterPlaceholder = (accName, campaignId) => {
  return {
    actions: [{
      account: `${process.env.ACC_NAME}`,
      name: 'addvoter',
      authorization: [{
        actor: `${process.env.ACC_NAME}`,
        permission: 'active',
      }],
      data: {
        campaign_id : campaignId,
        voter : accName
      },
    }]
  }
}

let regex = new RegExp('[a-z]([a-z]|\.|[1-5]){10}[^\.]');

const eosNameValidation = (name) => {
  return regex.test(name) & name.length == 12;
}

// const eosPublicKeyValidation = (publicKey) => {
//   console.log(publicKey)
//   console.log(ecc.isValidPublic(publicKey))
//   return ecc.isValidPublic(publicKey) === true;
// }

module.exports = {
  accountPlaceholder, 
  createVoterPlaceholder, 
  eosNameValidation,
  addVoterPlaceholder
  // eosPublicKeyValidation
}