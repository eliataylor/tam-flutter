const fs = require('fs');
const url = require('url');
const execSync = require("child_process").execSync;
const appCredentials = require('../../tam-typescript/build.local.json');

appCredentials.forEach((brand) => {

    const myurl = url.parse(brand.client_domain);


    const env = `APP_PACKAGE_ID=com.${brand.env.REACT_APP_TACLIENT_DIR}
APP_ID=${brand.env.REACT_APP_TACLIENT_DIR}
CLIENT_HOST=${myurl.host}
TAM_GID=${brand.gid}
APP_NAME=${brand.env.REACT_APP_NAME}`

    fs.writeFileSync(`.env.${brand.env.REACT_APP_TACLIENT_DIR}`, env, 'utf8');

});