var PaymentsContract = artifacts.require("PAYMENTS");
var MintContract = artifacts.require("BDDCMint");
var GameContract = artifacts.require("BDDCGame");

module.exports = function(deployer){
  //************************ PAYMENTS *****************************//
  // const _payees = ["0xb357E44d621F4740a15270d66E5B7f452E07Bbd8"];
  // const _shares = [1];
  //************************ PAYMENTS *****************************//

  //************************ BDDCMint *****************************//
  const _metadataURI = "https://gateway.pinata.cloud/ipfs/QmWd93y42ye4zKAC19QTcDHkxzoeBfcSumLDdFEPvJJkdk"
  const _payments = "0x9C20bc8309569070DEc6D705B8F1D61EB815f60c";
  //************************ BDDCMint *****************************//

  // deployer.deploy(PaymentsContract, _payees, _shares); // PAYMENTS
  deployer.deploy(MintContract, _metadataURI, _payments); // BDDCMint
  // deployer.deploy(GameContract, _payments); // BDDCGame

};