import 'package:eosdart/eosdart.dart' as eos;
// import 'dart:io' show Platform;

const String backendServerUrl = "http://34.81.225.93:3000";
const String keyPairURL = "https://eosauthority.com/generate_eos_private_key";
const String eosEndPoint = "https://api.testnet.eos.io"; // testnet
const String contractAccount = 'eimeutmhpudu'; // testnet
// const String eosEndPoint = "https://mainnet.eosn.io/"; // mainnet

eos.EOSClient client = eos.EOSClient(eosEndPoint, 'v1');
