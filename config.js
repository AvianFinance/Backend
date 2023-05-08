// ins_impl_token = "0x9f513D7299d8B850Bf0fa606E222358ab04cE7b8"
// ins_proxy_token = "0xFf0867165415bF58dC3498a521761Db8e77B281c"

// rent_impl_token = "0xD946719113666a3E78cc9B9FDEE0aD1a3adEd43b"
// rent_proxy_token = "0xE7e9137732c4eE0f6287a3b6356B48C10542c066"

// sell_impl_token = "0xeea30f42a31289CA91E06c265bd20700a0cC9666"
// sell_proxy_token = "0xDdd526e1F50C8842CD1Bd59c0e05Aa4F35Ee2fc5"

const fs = require('fs');

sell_proxy_addr = "0xDdd526e1F50C8842CD1Bd59c0e05Aa4F35Ee2fc5"
rent_proxy_addr = "0xE7e9137732c4eE0f6287a3b6356B48C10542c066"
installment_proxy_addr = "0xFf0867165415bF58dC3498a521761Db8e77B281c"
rime_token   = "0x4909493F604AB882327ca880ad5B330e2B3C43C1"
rime_rent = "0x43338C0F9749C0f69662C7ca4CfCF1b4a5b75203"

wrapper_list =  fs.readFileSync("wrapper_config.txt", "utf-8").split("\n").slice(0, -1);

module.exports = {
    sell_proxy_addr,
    rent_proxy_addr,
    installment_proxy_addr,
    rime_token,
    rime_rent,
    wrapper_list
};