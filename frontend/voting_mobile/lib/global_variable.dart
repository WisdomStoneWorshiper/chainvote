import 'package:eosdart/eosdart.dart' as eos;

const String backendServerUrl = "http://localhost:3000";
const String eosEndPoint = "https://api.testnet.eos.io"; // testnet
const String contractAccount = 'eimeutmhpudu'; // testnet
// const String eosEndPoint = "https://mainnet.eosn.io/"; // mainnet

eos.EOSClient client = eos.EOSClient(eosEndPoint, 'v1');
