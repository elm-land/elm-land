const fs = require('fs')
const path = require('path')

const plugin = () => {
    return {
        name: 'dot-path-fix-plugin',
        configureServer: (server) => {
            server.middlewares.use((req, _, next) => {
                const reqPath = req.url.split('?', 2)[0];
                if (reqPath == '/main.js') {
                    next()
                } else {
                    if (!req.url.startsWith('/@') && !fs.existsSync(`.${reqPath}`) && !fs.existsSync(path.join(server.config.publicDir, reqPath))) {
                        req.url = '/';
                    }
                    next();
                }
            });
        }
    }
};

module.exports = {
    plugin
}
