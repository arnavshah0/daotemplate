const DT = artifacts.require("daotemplate");

module.exports = async function (deployer) {
    await deployer.deploy(DT, "test", "TTT", 10, 10, 10);
};