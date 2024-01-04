const fs = require('fs')
const path = require('path')

const plugin = (props = {}) => {
    return {
        name: 'dot-path-fix-plugin',
        configureServer: (server) => {
            server.middlewares.use((req, _, next) => {
                const reqPath = req.url.split('?', 2)[0]

                // Ignore this logic if the proxy should handle it instead
                if (props.proxy) {
                    for (let key in props.proxy) {
                        let match = new RegExp(key).exec(reqPath)
                        if (match) {
                            return next()
                        }
                    }
                }

                const publicReqPath = path.join(server.config.publicDir, decodeURI(reqPath));
                if (reqPath == '/main.js') {
                    next()
                } else {
                    if (!req.url.startsWith('/@') && !fs.existsSync(`.${reqPath}`) && !fs.existsSync(`${publicReqPath}`)) {
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
