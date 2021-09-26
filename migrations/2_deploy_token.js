var FeeToken = artifacts.require("./FeeToken.sol");

module.exports = function (deployer) {
    deployer.deploy(FeeToken);
};
