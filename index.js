const { spawn } = require('child_process');
const http = require('http');
const fs = require('fs');

const logger = console;

const restartDNS = () => new Promise((resolve, reject) => {
  const proc = spawn('/etc/init.d/named', ['restart'], { shell: true });
  proc.stdout.on('data', data => {
    logger.info(`DNS restart message: ${data}`);
  });
  proc.stderr.on('data', data => {
    logger.error(`DNS restart error: ${data}`);
  });
  proc.on('close', code => {
    if (code !== 0) {
      reject(new Error(`DNS restart process exited with code ${code}`));
      return;
    }
    resolve('DNS restarted successfully');
  });
});

const ddnsService = async (data, domain) => {
  const payload = JSON.parse(data);
  if (!Array.isArray(payload) || !payload.length) {
    throw new Error('JSON do not valid');
  }
  const dbPath = `db.${domain}`;
  let zoneData = fs.readFileSync(dbPath, 'utf8');
  payload.forEach(({ sub, ip }) => {
    const regex = new RegExp(`${sub.replace('*', '\\*')}\\s+IN\\s+A\\s+[0-9.]+`, 'm');
    zoneData = zoneData.replace(regex, `${sub} IN A ${ip}`);
  });
  fs.writeFileSync(dbPath, zoneData);
  await restartDNS();
};

const ddnsController = (req, res) => {
  const { url } = req;
  const [, , domain] = url.split('/');
  let data = '';
  req.on('data', chunk => { data += chunk; });
  req.on('end', async () => {
    await ddnsService(data, domain)
    .then(() => {
      res.writeHead(200);
      res.end('Zone file updated successfully');
    })
    .catch(e => {
      logger.error(e);
      if (e.message.match(/JSON/)) {
        res.writeHead(400);
        res.end('Bad Request');
        return;
      }
      res.writeHead(500);
      res.end('Internal Server Error');
    });
  });
};

const route = (req, res) => {
  const { method, url } = req;
  const [, endpoint, domain] = url.split('/');
  if (method === 'POST' && endpoint === 'ddns' && domain) {
    ddnsController(req, res);
  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
};

const server = http.createServer(route);

const PORT = Number.parseInt(process.env.PORT, 10) || 3000;
server.listen(PORT, () => {
  logger.info(`Server running at http://127.0.0.1:${PORT}/`);
});
