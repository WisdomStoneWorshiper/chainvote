# votingplat

## Smart Contract Compile Guide

To compile this contract, please follow the following instruction.

1. Check out to this folder with terminal
2. Compile the contract with
    `eosio-cpp -abigen -I include -R resource -contract votingplat -o votingplat.wasm src/votingplat.cpp`

## Testing

To perform the coverage testing for the smart contract, we used Hydra library, which require some setup:

- Create an account on [Hydra Homepage](https://klevoya.com/hydra/)
- Follow the documentation on [Hydra Documentation](https://docs.klevoya.com/hydra/about/getting-started)

By then, when you run `npm test`, the coverage test will start

> If there is missing packages, try running `npm i` before running `npm test`
