/* eslint no-underscore-dangle: [2, { "allow": ["_logInfo", "_logError", "_logDebug"] }] */
/* eslint import/no-dynamic-require: 0 */
const winston = require('winston');
const fs = require('fs');
const path = require('path');
const { check } = require('../util/environmentCheck.js');
/* The environment variable LOGGERCONFIG will contain the path to the config file.
  The actual path for the config is "../deploy/configs/util/logger.json"
  For the docker containers, the path is /etc/util/logger.json */
check('LOGGERCONFIG');

const config = require(process.env.LOGGERCONFIG);

const timeStampFormat = () => (new Date()).toJSON();

const createLoggerObject = function createLoggerObject(logDirectory, component, logLevel) {
  return new (winston.Logger)({
    transports: [
      new (winston.transports.File)({
        name: `${logLevel}Log`,
        filename: path.join(logDirectory, `${component.role}_${component.hostname}_${component.port}_${logLevel}.log`),
        json: true,
        level: `${logLevel}`,
        timestamp: timeStampFormat,
        maxsize: config.maxSize,
      }),
    ],
  });
};

class Logger {
  constructor(component) {
    if (config.roles.includes(component.role) && component.hostname !== undefined
    && component.port !== undefined) {
      this.logDirectory = config.logDirectory;
      this.componentRole = component.role;
      // Create the log directory if it does not exist
      if (!fs.existsSync(this.logDirectory)) {
        fs.mkdirSync(this.logDirectory, (err) => {
          if (err) {
            console.log(err);
            throw new Error('Error in creating the log directory.');
          }
        });
      }
      this._logError = createLoggerObject(this.logDirectory, component, 'error');
      this._logInfo = createLoggerObject(this.logDirectory, component, 'info');
      this._logDebug = createLoggerObject(this.logDirectory, component, 'debug');
    }
  }

  error(log) {
    if (this._logError !== undefined) {
      this._logError.log('error', log);
    }
  }

  info(log) {
    if (this._logInfo !== undefined) {
      this._logInfo.log('info', log);
    }
  }

  debug(log) {
    if (this._logDebug !== undefined) {
      this._logDebug.log('debug', log);
    }
  }
}

module.exports.Logger = Logger;
