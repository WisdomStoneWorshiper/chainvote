# Backend Server

## Setup
To run the server,
- Install the latest Node.Js from https://nodejs.org/en/download/
- From this ./fyp/backend folder, run
`npm i`, followed by `npm start`. The server will run at http://localhost:3000/
> If the server does not start due to missing variables/ API key. It is possible that the .env for the server is misplaced. For security reason, the .env is not uploaded to the GitHub and will be saved locally when submitting the project

> If the server does not start due to another Port occupying the same port, you can switch the port number at .env at SERVER_PORT section

## Testing
To test the server function, run `npm test` on the root folder. The test will run itself and show the result of the coverage test for the backend

To test the blockchain perfomance test, run `npm run performance <Number of Accounts>` on the root folder (Max 100 accounts). This will simulate the asynchronous voting testing to the voting system.
> Since the testing happens on the testnet, forking sometimes occurs in the middle of the testing, which could remove the created campaign for this testing. If this occurs, just `ctrl+c` and run the command again

