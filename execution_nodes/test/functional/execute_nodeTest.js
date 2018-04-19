const dns = require('dns');
const chai = require('chai');
const dirtyChai = require('dirty-chai');
const request = require('request');
const nock = require('nock');
const sinon = require('sinon');
const { requestRunData } = require('./data/submission.json');
const { check } = require('../../../util/environmentCheck.js');

check('ENCONFIG');
check('ENSCORES');
// eslint-disable-next-line import/no-dynamic-require
const conf = require(`../../${process.env.ENCONFIG}`);
// eslint-disable-next-line import/no-dynamic-require
const scores = require(`../../${process.env.ENSCORES}`);
const enUrl = `https://${conf.execution_node.hostname}:${conf.execution_node.port}`;
const lbUrl = `https://${conf.load_balancer.hostname}:${conf.load_balancer.port}`;
chai.should();
chai.use(dirtyChai);
let executeNode;
let logStub;
const sandbox = sinon.createSandbox();

const activateNocks = function activateNocks() {
  if (!nock.isActive()) {
    nock.activate();
  }
};

const cleanNocks = function cleanNocks() {
  nock.cleanAll();
  nock.restore();
};

const stubConsole = function startExecutionNode() {
  logStub = sandbox.stub(console, 'log');
};

const restoreConsole = function stopExecutionNode() {
  logStub = {};
  sandbox.restore();
};

const startExecutionNode = function startExecutionNode() {
  delete require.cache[require.resolve('../../execute_node.js')];
  // eslint-disable-next-line global-require
  executeNode = require('../../execute_node.js');
};

describe('HTTP calls are successful', () => {
  const checkLbRequest = function checkLbRequest(requestCase, response) {
    stubConsole();
    const { submission, result } = requestRunData.find(data => data.case === requestCase);
    nock(lbUrl)
      .post('/sendScores')
      .reply(200, (uri, requestBody) => {
        requestBody.should.have.all.keys('node_details', 'submission_details');
        requestBody.node_details.should.deep.equal(scores.node_details);
        requestBody.submission_details.should.deep.equal(result);
        restoreConsole();
        response();
        return true;
      });
    request.post(`${enUrl}/requestRun`, { json: submission });
  };

  beforeEach(() => {
    stubConsole();
    startExecutionNode();
    restoreConsole();
    activateNocks();
  });

  afterEach((done) => {
    cleanNocks();
    executeNode.server.close(done);
  });

  it('Connection check returns true', (done) => {
    stubConsole();
    request.get(`${enUrl}/connectionCheck`, (error, response) => {
      (error === null).should.be.true();
      response.body.should.equal('true');
      restoreConsole();
      done();
    });
  });

  it('Request run for a normal evaluation', (done) => {
    checkLbRequest('normal_evaluation', () => {
      done();
    });
  });

  it('Request run when results directory does not exist', (done) => {
    process.env.TEST_ACTION = 'delete_results';
    checkLbRequest('results_directory_missing', () => {
      process.env.TEST_ACTION = '';
      done();
    });
  });

  it('Request run when executable binary does not exist', (done) => {
    checkLbRequest('binary_missing', () => {
      done();
    });
  });

  it('Request run when language is not supported by instructor', (done) => {
    checkLbRequest('unsupported_language', () => {
      done();
    });
  });

  it('Request run when submit language does not exist', (done) => {
    checkLbRequest('unavailable_language', () => {
      done();
    });
  });
});

describe('Load balancer receives request at node startup', () => {
  beforeEach(() => {
    activateNocks();
  });

  afterEach((done) => {
    cleanNocks();
    executeNode.server.close(done);
  });

  it('Add node request when load balancer is up', (done) => {
    stubConsole();
    nock(lbUrl)
      .post('/addNode')
      .delay(1000)
      .reply(200, (uri, requestBody) => {
        requestBody.should.have.all.keys('role', 'hostname', 'port');
        requestBody.should.deep.equal(scores.node_details);
        restoreConsole();
        done();
        return true;
      });
    startExecutionNode();
  });

  it('Add node request when load balancer is down', (done) => {
    stubConsole();
    startExecutionNode();
    setTimeout(() => {
      sinon.assert.calledTwice(logStub);
      sinon.assert.calledWith(logStub.firstCall, `Listening at ${conf.execution_node.port}`);
      sinon.assert.calledWith(logStub.secondCall, sinon.match.has('code', 'ECONNREFUSED'));
      sinon.assert.calledWith(logStub.secondCall, sinon.match.has('port', parseInt(conf.load_balancer.port, 10)));
      dns.lookup(conf.load_balancer.hostname, (err, address) => {
        if (!err) {
          sinon.assert.calledWith(logStub.secondCall, sinon.match.has('address', address));
          restoreConsole();
          done();
        }
      });
    }, 5);
  });
});

describe('Config file not present', () => {
  const missingConfigFile = function missingConfigFile(envVariable, response) {
    delete process.env[envVariable];
    (startExecutionNode.bind(startExecutionNode)).should.throw(Error, 'Path to config file is not specified.');
    response();
  };

  let enConfig;
  let enScores;
  before(() => {
    enConfig = process.env.ENCONFIG;
    enScores = process.env.ENSCORES;
  });
  after(() => {
    process.env.ENCONFIG = enConfig;
    process.env.ENSCORES = enScores;
  });

  it('Path for conf.json is invalid', (done) => {
    missingConfigFile('ENCONFIG', () => {
      done();
    });
  });

  it('Path for scores.json is invalid', (done) => {
    missingConfigFile('ENSCORES', () => {
      done();
    });
  });
});
