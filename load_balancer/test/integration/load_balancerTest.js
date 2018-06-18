console.log('======integration tests on load balancer======\n');

const chai = require('chai');
const dirtyChai = require('dirty-chai');
const request = require('request');
const nock = require('nock');
const dns = require('dns');
const sinon = require('sinon');
const { check } = require('../../../util/environmentCheck.js');
const testData = require('./data/submission.json');
// eslint-disable-next-line import/no-dynamic-require
const configData = require(`../../${process.env.LBCONFIG}`);
const lbUrl = `https://${configData.load_balancer.hostname}:${configData.load_balancer.port}`;
const sandbox = sinon.createSandbox();

let loadBalancer;
let logStub;

check('LBCONFIG');

chai.should();
chai.use(dirtyChai);

const activateNocks = function activateNocks() {
  if (!nock.isActive()) {
    nock.activate();
  }
};

const cleanNocks = function cleanNocks() {
  nock.cleanAll();
  nock.restore();
};

const stubConsole = function stubConsole() {
  logStub = sandbox.stub(console, 'log');
};

const restoreConsole = function restoreConsole() {
  logStub = {};
  sandbox.restore();
};

const startLoadBalancer = function startLoadBalancer() {
  delete require.cache[require.resolve('../../load_balancer.js')];
  // eslint-disable-next-line global-require
  loadBalancer = require('../../load_balancer.js');
};

const mockENStatus = function mockENStatus(url, returnVal) {
  const nockObj = nock(url)
    .get('/connectionCheck')
    .reply(200, returnVal);
  return nockObj;
};

const requestRunNock = function requestRunNock(url) {
  const tempJob = testData.submissionsData[0];
  const nockObj = nock(url)
    .persist()
    .post('/requestRun')
    .reply(200, (uri, requestBody) => {
      requestBody.should.have.all.keys('id_no', 'Lab_No', 'time', 'commit', 'status', 'penalty', 'socket', 'language');
      requestBody.should.deep.equal(tempJob);
      return true;
    });
  return nockObj;
};

const connectionCheckAssert = function connectionCheckAssert(upArray, resp) {
  request.get(`${lbUrl}/connectionCheck`, (error, response) => {
    const responseBody = JSON.parse(response.body);
    responseBody.components.forEach((elem, index) => {
      if (upArray.includes(index)) {
        elem.status.should.equal('up');
      } else {
        elem.status.should.equal('down');
      }
    });
    restoreConsole();
    resp();
  });
};

const jobSubmitCheck = function jobSubmitCheck() {
  const tempJob = testData.submissionsData[0];
  request.post(`${lbUrl}/submit`, { json: tempJob }, (error, response) => {
    (error === null).should.be.true();
    response.body.should.equal(true);
  });
};

describe('Correctly maintains list of ENs', () => {
  beforeEach(() => {
    stubConsole();
    startLoadBalancer();
    restoreConsole();
    activateNocks();
  });

  afterEach((done) => {
    cleanNocks();
    loadBalancer.server.close(done);
  });

  it('during status check', (done) => {
    stubConsole();
    const res = JSON.parse(JSON.stringify(configData.Nodes));
    const lbTestStatus = configData.load_balancer;
    lbTestStatus.status = 'up';
    [0, 1].forEach((elem) => {
      mockENStatus(`https://${res[elem].hostname}:${res[elem].port}`, true);
      mockENStatus(`https://${res[elem].hostname}:${res[elem].port}`, true);
    });
    request.get(`${lbUrl}/connectionCheck`, (error, response) => {
      const responseBody = JSON.parse(response.body);
      response.should.exist();
      responseBody.should.have.all.keys('components', 'job_queue_length', 'timestamp');
      responseBody.job_queue_length.should.equal(loadBalancer.job_queue.length);
      responseBody.timestamp.should.be.a('string');
      responseBody.components.should.be.an('array');
      responseBody.components.should.deep.include(lbTestStatus);
      responseBody.components.forEach((elem, index) => {
        if (index === 0 || index === 1 || index === 10) {
          elem.status.should.equal('up');
        } else {
          elem.status.should.equal('down');
        }
      });
      restoreConsole();
      done();
    });
  });
});

describe('Correctly adds a newly started node', () => {
  beforeEach(() => {
    stubConsole();
    startLoadBalancer();
    restoreConsole();
    activateNocks();
  });

  afterEach((done) => {
    cleanNocks();
    loadBalancer.server.close(done);
  });

  const addNodeCheck = function addNodeCheck(jobPending, resp) {
    const tempNode = testData.nodesData[0];
    stubConsole();
    mockENStatus(`https://${tempNode.hostname}:${tempNode.port}`, false);
    mockENStatus(`https://${tempNode.hostname}:${tempNode.port}`, true);
    const requestRunNockObj = requestRunNock(`https://${tempNode.hostname}:${tempNode.port}`);
    if (jobPending) {
      jobSubmitCheck();
    }
    request.post(`${lbUrl}/addNode`, { json: tempNode });
    setTimeout(() => {
      requestRunNockObj.isDone().should.equal(jobPending);
      connectionCheckAssert([0, 10], () => {
        resp();
      });
    }, 50);
  };

  it('when no job is pending', (done) => {
    addNodeCheck(false, () => {
      done();
    });
  });

  it('when a job is pending', (done) => {
    addNodeCheck(true, () => {
      done();
    });
  });

  it('when incorrect EN sends addNode request', (done) => {
    const wrongNode = {
      role: 'execution_node',
      hostname: 'localhost',
      port: '8087',
    };
    const tempJob = testData.submissionsData[0];
    stubConsole();
    jobSubmitCheck();
    setTimeout(() => {
      request.post(`${lbUrl}/addNode`, { json: wrongNode });
    }, 50);
    setTimeout(() => {
      sinon.assert.calledWith(logStub.getCall(1), sinon.match(tempJob));
      sinon.assert.calledWith(logStub.getCall(3), sinon.match(wrongNode));
      sinon.assert.calledWith(logStub.getCall(5), sinon.match.has('code', 'ECONNREFUSED'));
      sinon.assert.calledWith(logStub.getCall(5), sinon.match.has('port', parseInt(wrongNode.port, 10)));
      dns.lookup(wrongNode.hostname, (err, address) => {
        if (!err) {
          sinon.assert.calledWith(logStub.getCall(5), sinon.match.has('address', address));
          restoreConsole();
          done();
        }
      });
    }, 100);
  });
});

describe('Correctly accepts jobs', () => {
  beforeEach(() => {
    stubConsole();
    startLoadBalancer();
    restoreConsole();
    activateNocks();
  });

  afterEach((done) => {
    cleanNocks();
    loadBalancer.server.close(done);
  });

  it('when no node is available', (done) => {
    stubConsole();
    jobSubmitCheck();
    connectionCheckAssert([10], () => {
      done();
    });
  });

  it('when node is available to process request', (done) => {
    const tempNode = testData.nodesData[0];
    stubConsole();
    mockENStatus(`https://${tempNode.hostname}:${tempNode.port}`, true);
    mockENStatus(`https://${tempNode.hostname}:${tempNode.port}`, true);
    const requestRunNockObj = requestRunNock(`https://${tempNode.hostname}:${tempNode.port}`);
    jobSubmitCheck();
    setTimeout(() => {
      requestRunNockObj.isDone().should.equal(true);
      connectionCheckAssert([0, 10], () => {
        done();
      });
    }, 50);
  });
});
