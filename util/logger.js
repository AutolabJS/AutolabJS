const winston = require('winston');
const fs = require('fs');

const logDir = 'log';
const timeStampFormat = () => (new Date()).toLocaleTimeString();

// Create the log directory if it does not exist
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir);
}

const logger = new (winston.Logger)({
  transports: [
    // colorize the output to the console
    new (winston.transports.Console)({
      timestamp: timeStampFormat,
      colorize: true,
      level: 'info',
    }),
    new (winston.transports.File)({
      filename: `${logDir}/componentLog.txt`,
      timestamp: timeStampFormat,
      level: 'debug',
    }),
  ],
});

logger.debug('===============Information logging started===============');

module.exports = logger;
