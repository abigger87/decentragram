const Decentragram = artifacts.require('Decentragram')

module.exports = async function(callback) {
  let decentragram = await Decentragram.deployed()
  //await decentragram.issueTokens()
  // Code goes here...
  console.log("Decentragram contract is deployed!")
  callback()
}
