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

const addVoterPlaceholder = (name) => {
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

module.exports = {accountPlaceholder, addVoterPlaceholder}