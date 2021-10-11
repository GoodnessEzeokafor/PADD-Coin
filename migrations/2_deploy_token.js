var PaddToken = artifacts.require('PaddToken.sol');

module.exports = function (deployer) {
    deployer.deploy(PaddToken);
};
