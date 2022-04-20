# votingplat

This example is to demonstrate a basic EOSIO smart contract, including

- Define contract actions
- Define a table
- Perform read/write/remove operations on the table

## Testing

To perform the coverage testing for the smart contract, we used Hydra library, which require some setup:

- Create an account on [Hydra Homepage](https://klevoya.com/hydra/)
- Follow the documentation on [Hydra Documentation](https://docs.klevoya.com/hydra/about/getting-started)

By then, when you run `npm test`, the coverage test will start

> If there is missing packages, try running `npm i` before running `npm test`