/* eslint no-underscore-dangle: [2, { "allow": ["__get__", "_logInfo", "_logError",
"_logDebug"] }] */
/* eslint import/no-dynamic-require: 0 */

/* The writing in log file is async. Hence, even after specifying a wait period,
there is a chance the tests may fail. */

const chai = require('chai');
const winston = require('winston');
const { Logger } = require('../logger.js');
const { exec } = require('child_process');
const fs = require('fs');
const chaiFs = require('chai-fs');
const path = require('path');
const dirtyChai = require('dirty-chai');
const rewire = require('rewire');

const config = require(`../${process.env.LOGGERCONFIG}`);

const logDirectory = config.logDirectory;
const createLoggerObject = rewire('../logger.js').__get__('createLoggerObject');

chai.should();
chai.use(chaiFs);
chai.use(dirtyChai);

/* These variables will be used in the following tests.
They have been declared in the global space to avoid repetition. */
let lbLogger;
let msLogger;
const lbLoggerConfig = {
  role: 'load_balancer',
  hostname: 'localhost',
  port: '8081',
  cmd: 'log',
};
const msLoggerConfig = {
  role: 'main_server',
  hostname: 'localhost',
  port: '9000',
  cmd: 'log',
};
const logMessages = ['Error message', 'Debug message', 'Info message'];
const logLevels = ['error', 'debug', 'info'];
const fileNamePrefix = `${lbLoggerConfig.role}_${lbLoggerConfig.hostname}_${lbLoggerConfig.port}`;

const logs = logLevels.map(x => `${fileNamePrefix}_${x}.log`);

const logPaths = logs.map(x => path.join(logDirectory, x));

const deleteLogDirectory = function deleteLogDirectory(response) {
  exec(`rm -rf ${logDirectory}`, (error) => {
    if (error) {
      console.error(`exec error in deleting log directory: ${error}`);
      response(false);
    }
    response(true);
  });
};

const fileContentChecker = function fileContentChecker(fileName, message, level, response) {
  const filePath = path.join(logDirectory, fileName);
  const fileContent = fs.readFileSync(filePath, 'utf8');
  (JSON.parse(fileContent).message).should.equal(message);
  (JSON.parse(fileContent).level).should.equal(level);
  response();
};

describe('Helper functions work correctly', () => {
  it('Deletes log directory', (done) => {
    fs.mkdirSync(logDirectory);
    logDirectory.should.be.a.directory().and.empty();
    deleteLogDirectory(() => {
      logDirectory.should.not.be.a.path();
      done();
    });
  });

  it('File gets written properly', (done) => {
    const writeData = {
      message: logMessages[0],
      level: logLevels[0],
    };
    fs.mkdirSync(logDirectory);
    fs.writeFileSync(logPaths[0], JSON.stringify(writeData), 'utf8');
    fileContentChecker(logs[0], logMessages[0], logLevels[0], () => {
      deleteLogDirectory(() => {
        done();
      });
    });
  });
});

describe('Creates a logger object', () => {
  it('Method createLoggerObject works correctly', () => {
    lbLogger = createLoggerObject(logDirectory, lbLoggerConfig, logLevels[0]);
    lbLogger.should.be.an.instanceOf(winston.Logger);
    lbLogger.transports.errorLog.level.should.equal(logLevels[0]);
    lbLogger.transports.errorLog.json.should.equal(true);
    lbLogger.transports.errorLog.name.should.equal(`${logLevels[0]}Log`);
    lbLogger.transports.errorLog.timestamp.should.be.a('function');
  });

  it('Incorrect config results in empty logger object', (done) => {
    lbLogger = new Logger({});
    lbLogger.should.be.empty();
    logDirectory.should.not.be.a.path();
    done();
  });

  it('Correct config results in a properly configured logger object', (done) => {
    lbLogger = new Logger(lbLoggerConfig);
    Object.keys(lbLogger).length.should.equal(5);
    logDirectory.should.be.a.directory().and.empty();
    lbLogger.should.have.a.property('logDirectory', '../log');
    lbLogger.should.have.a.property('componentRole', 'load_balancer');
    lbLogger.should.have.a.property('_logDebug');
    lbLogger.should.have.a.property('_logInfo');
    lbLogger.should.have.a.property('_logError');
    lbLogger._logDebug.should.be.an.instanceOf(winston.Logger);
    lbLogger._logInfo.should.be.an.instanceOf(winston.Logger);
    lbLogger._logError.should.be.an.instanceOf(winston.Logger);
    deleteLogDirectory(() => {
      done();
    });
  });
});

describe('Log files are written correctly', () => {
  const directoryContentChecker = function directoryContentChecker(acceptedLogFiles,
    unacceptedLogFiles, response) {
    logDirectory.should.be.a.directory().with.files(acceptedLogFiles);
    logDirectory.should.be.a.directory().and.not.have.files(unacceptedLogFiles);
    response();
  };

  const testSingleLogFile = function testFunction(logType, response) {
    const filename = logs[logType];
    const message = logMessages[logType];
    const level = logLevels[logType];
    const acceptedLogFiles = Array.of(logs[logType]);
    const unacceptedLogFiles = Array.of(logs.slice(0, logType) + logs.slice(logType + 1));
    lbLogger[level](message);
    setTimeout(() => {
      directoryContentChecker(acceptedLogFiles, unacceptedLogFiles, () => {
        fileContentChecker(filename, message, level, () => {
          response();
        });
      });
    }, 10);
  };

  const testTwoLogFiles = function testTwoLogFiles(logType1, logType2, unacceptedLog,
    response) {
    lbLogger[logLevels[logType1]](logMessages[logType1]);
    lbLogger[logLevels[logType2]](logMessages[logType2]);
    const acceptedLogFiles = [logs[logType1], logs[logType2]];
    const unacceptedLogFiles = [logs[unacceptedLog]];
    setTimeout(() => {
      directoryContentChecker(acceptedLogFiles, unacceptedLogFiles, () => {
        fileContentChecker(logs[logType1], logMessages[logType1], logLevels[logType1], () => {
          fileContentChecker(logs[logType2], logMessages[logType2], logLevels[logType2], () => {
            response();
          });
        });
      });
    }, 5);
  };

  beforeEach((done) => {
    lbLogger = new Logger(lbLoggerConfig);
    done();
  });

  afterEach((done) => {
    deleteLogDirectory(() => {
      done();
    });
  });

  it('Error message is logged correctly', (done) => {
    testSingleLogFile(0, () => {
      done();
    });
  });

  it('Debug message is logged correctly', (done) => {
    testSingleLogFile(1, () => {
      done();
    });
  });

  it('Info message is logged correctly', (done) => {
    testSingleLogFile(2, () => {
      done();
    });
  });

  it('Error and debug messages are logged to respective files', (done) => {
    testTwoLogFiles(0, 1, 2, () => {
      done();
    });
  });

  it('Error and info messages are logged to respective files', (done) => {
    testTwoLogFiles(0, 2, 1, () => {
      done();
    });
  });

  it('Info and debug messages are logged to respective files', (done) => {
    testTwoLogFiles(2, 1, 0, () => {
      done();
    });
  });
});

describe('Two independent logger objects behave correctly', () => {
  const testLoggingOfTwoLoggers = function testLoggingOfTwoLoggers(logLevel1, logLevel2,
    logMessage1, logMessage2, logFile1, logFile2, response) {
    lbLogger[logLevel1](logMessage1);
    msLogger[logLevel2](logMessage2);
    setTimeout(() => {
      fileContentChecker(logFile1, logMessage1, logLevel1, () => {
        fileContentChecker(logFile2, logMessage2, logLevel2, () => {
          response();
        });
      });
    }, 5);
  };
  const msLog = `${msLoggerConfig.role}_${msLoggerConfig.hostname}_${msLoggerConfig.port}`;

  beforeEach((done) => {
    lbLogger = new Logger(lbLoggerConfig);
    msLogger = new Logger(msLoggerConfig);
    done();
  });

  afterEach((done) => {
    deleteLogDirectory(() => {
      done();
    });
  });

  it('Logger objects are created properly', (done) => {
    Object.keys(lbLogger).length.should.equal(5);
    Object.keys(msLogger).length.should.equal(5);
    logDirectory.should.be.a.directory().and.empty();
    lbLogger.should.have.a.property('componentRole', 'load_balancer');
    msLogger.should.have.a.property('componentRole', 'main_server');
    done();
  });

  it('Log messages go to correct files for same log level', (done) => {
    const msErrorLogMessage = 'Second Error Message';
    const msErrorLog = `${msLog}_${logLevels[0]}.log`;
    testLoggingOfTwoLoggers(logLevels[0], logLevels[0], logMessages[0],
      msErrorLogMessage, logs[0], msErrorLog, () => {
        done();
      });
  });

  it('Log messages go to correct files for different log level', (done) => {
    const msDebugLog = `${msLog}_${logLevels[1]}.log`;
    testLoggingOfTwoLoggers(logLevels[0], logLevels[1], logMessages[0],
      logMessages[1], logs[0], msDebugLog, () => {
        done();
      });
  });
});
