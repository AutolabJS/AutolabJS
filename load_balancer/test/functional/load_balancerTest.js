const chai = require('chai');
const dirtyChai = require('dirty-chai');
const request = require('request');
const nock = require('nock');
const dns = require('dns');
const sinon = require('sinon');
const mysql = require('mysql');
const { check } = require('../../../util/environmentCheck.js');
const testData = require('./data/submission.json');
// eslint-disable-next-line import/no-dynamic-require
const configData = require(`../../${process.env.LBCONFIG}`);
const lbUrl = `https://${configData.load_balancer.hostname}:${configData.load_balancer.port}`;
const msUrl = `https://${configData.server_info.hostname}:${configData.server_info.port}`;
const sandbox = sinon.createSandbox();

let loadBalancer;
let logStub;
let mysqlConnection;

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

const startMysqlConnection = function startMysqlConnection() {
  const labNo = testData.executedJob.submission_details.Lab_No;
  try {
    mysqlConnection = mysql.createConnection(configData.database);
    mysqlConnection.connect();
    let q = `DROP TABLE IF EXISTS l${labNo}`;
    mysqlConnection.query(q, (err, rows, fields) => {
      console.log('Delete Query', err, rows, fields);
    });
    q = `CREATE TABLE l${labNo}(id_no varchar(30), score int, time datetime, PRIMARY KEY (id_no))`;
    mysqlConnection.query(q, (err, rows, fields) => {
      console.log('Create Query', err, rows, fields);
    });
  } catch (e) {
    console.log(e);
  }
};

const sleepFunc = function sleepFunc(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
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
      requestBody.should.have.all.keys('id_no', 'Lab_No', 'time', 'commit', 'status',
        'penalty', 'socket', 'language');
      requestBody.should.deep.equal(tempJob);
      return true;
    });
  return nockObj;
};

const resultsNock = function resultsNock(failingTest, executedJobDetails) {
  const nockObj = nock(msUrl)
  .persist()
  .post('/results')
  .reply(200, (uri, requestBody) => {
    requestBody.should.have.all.keys('id_no', 'Lab_No', 'time', 'commit', 'status',
      'penalty', 'socket', 'marks', 'comment', 'log');
    requestBody.marks.should.be.an('array');
    requestBody.comment.should.be.an('array');
    requestBody.should.deep.equal(executedJobDetails.submission_details);
    if (failingTest) {
      requestBody.marks.length.should.not.equal(requestBody.comment.length);
    } else {
      requestBody.marks.length.should.equal(requestBody.comment.length);
    }
    return 'true';
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

const submitReqCheck = function submitReqCheck(executedJobDetails) {
  request.post(`${lbUrl}/sendScores`, { json: executedJobDetails }, (error, response) => {
    (error === null).should.be.true();
    response.body.should.equal(true);
  });
};

const testAssertion = function testAssertion(testDetails, nodeArray, resp) {
  setTimeout(() => {
    if (testDetails.requestRunNockObj != null) {
      testDetails.requestRunNockObj.isDone().should.equal(testDetails.requestRunVal);
    }
    if (testDetails.resultsNockObj != null) {
      testDetails.resultsNockObj.isDone().should.equal(testDetails.resultsVal);
    }
    connectionCheckAssert(nodeArray, () => {
      resp();
    });
  }, 100);
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

  it('when all ENs are down', (done) => {
    stubConsole();
    connectionCheckAssert([10], () => {
      done();
    });
  });

  /* it('when MySQL database is down', (done) => {
    stubConsole();
    loadBalancer.server.close();
    process.env.LBCONFIG = './test/functional/data/wrongConf.json';
    try {
      startLoadBalancer();
    } catch (err) {
      console.log('Error caught', err);
    }
    setTimeout(() => {
      console.log('Reached here')
      process.env.LBCONFIG = '../deploy/configs/load_balancer/nodes_data_conf.json';
      restoreConsole();
      done();
    }, 200);
  }); */
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
    const testDetails = {};
    const tempNode = testData.nodesData[0];
    stubConsole();
    mockENStatus(`https://${tempNode.hostname}:${tempNode.port}`, false);
    mockENStatus(`https://${tempNode.hostname}:${tempNode.port}`, true);
    testDetails.requestRunNockObj = requestRunNock(`https://${tempNode.hostname}:${tempNode.port}`);
    if (jobPending) {
      jobSubmitCheck();
    }
    request.post(`${lbUrl}/addNode`, { json: tempNode });
    testDetails.requestRunVal = jobPending;
    testAssertion(testDetails, [0, 10], resp);
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
    const testDetails = {};
    const tempNode = testData.nodesData[0];
    stubConsole();
    mockENStatus(`https://${tempNode.hostname}:${tempNode.port}`, true);
    mockENStatus(`https://${tempNode.hostname}:${tempNode.port}`, true);
    testDetails.requestRunNockObj = requestRunNock(`https://${tempNode.hostname}:${tempNode.port}`);
    jobSubmitCheck();
    testDetails.requestRunVal = true;
    testAssertion(testDetails, [0, 10], () => {
      done();
    });
  });
});

describe('Correctly accepts executed job results', () => {
  beforeEach(async () => {
    stubConsole();
    startMysqlConnection();
    await sleepFunc(200);
    startLoadBalancer();
    restoreConsole();
    activateNocks();
  });

  afterEach((done) => {
    cleanNocks();
    mysqlConnection.end();
    loadBalancer.server.close(done);
  });

  it('when no job is pending', (done) => {
    const testDetails = {};
    const execSubmissionObj = testData.executedJob;
    stubConsole();
    mockENStatus(`https://${execSubmissionObj.node_details.hostname}:${execSubmissionObj.node_details.port}`, false);
    mockENStatus(`https://${execSubmissionObj.node_details.hostname}:${execSubmissionObj.node_details.port}`, true);
    testDetails.requestRunNockObj = requestRunNock(`https://${execSubmissionObj.node_details.hostname}:${execSubmissionObj.node_details.port}`);
    testDetails.resultsNockObj = resultsNock(false, execSubmissionObj);
    submitReqCheck(execSubmissionObj);
    testDetails.resultsVal = true;
    testDetails.requestRunVal = false;
    testAssertion(testDetails, [0, 10], () => {
      done();
    });
  });

  it('when a job is pending', (done) => {
    const testDetails = {};
    const execSubmissionObj = testData.executedJob;
    stubConsole();
    testDetails.requestRunNockObj = requestRunNock(`https://${execSubmissionObj.node_details.hostname}:${execSubmissionObj.node_details.port}`);
    testDetails.resultsNockObj = resultsNock(false, execSubmissionObj);
    jobSubmitCheck();
    submitReqCheck(execSubmissionObj);
    testDetails.resultsVal = true;
    testDetails.requestRunVal = true;
    testAssertion(testDetails, [10], () => {
      done();
    });
  });
});

describe('Submits a job and receives result correctly', () => {
  beforeEach(async () => {
    stubConsole();
    startMysqlConnection();
    await sleepFunc(200);
    startLoadBalancer();
    restoreConsole();
    activateNocks();
  });

  afterEach((done) => {
    cleanNocks();
    mysqlConnection.end();
    loadBalancer.server.close(done);
  });

  it('for valid case', (done) => {
    const testDetails = {};
    const tempJob = testData.submissionsData[0];
    const execSubmissionObj = testData.executedJob;
    stubConsole();
    testDetails.resultsNockObj = resultsNock(false, execSubmissionObj);
    testDetails.requestRunNockObj = nock(`https://${execSubmissionObj.node_details.hostname}:${execSubmissionObj.node_details.port}`)
    .persist()
    .post('/requestRun')
    .reply(200, (uri, requestBody) => {
      requestBody.should.deep.equal(tempJob);
      submitReqCheck(execSubmissionObj);
      return true;
    });
    mockENStatus(`https://${execSubmissionObj.node_details.hostname}:${execSubmissionObj.node_details.port}`, true);
    mockENStatus(`https://${execSubmissionObj.node_details.hostname}:${execSubmissionObj.node_details.port}`, true);
    jobSubmitCheck();
    testDetails.resultsVal = true;
    testDetails.requestRunVal = true;
    testAssertion(testDetails, [0, 10], () => {
      done();
    });
  });

  it('with large logs of 30000 lines', (done) => {
    const testDetails = {};
    const execSubmissionObj = JSON.parse(JSON.stringify(testData.executedJob));
    let tempStr = 'Temporary string';
    let count = 30000;
    while (count > 0) {
      tempStr = `Temp \n${tempStr}`;
      count -= 1;
    }
    stubConsole();
    execSubmissionObj.submission_details.log = tempStr;
    testDetails.resultsNockObj = resultsNock(false, execSubmissionObj);
    submitReqCheck(execSubmissionObj);
    testDetails.resultsVal = true;
    testAssertion(testDetails, [10], () => {
      done();
    });
  });

  it('when EN sends invalid messages', (done) => {
    const testDetails = {};
    const execSubmissionObj = JSON.parse(JSON.stringify(testData.executedJob));
    stubConsole();
    execSubmissionObj.submission_details.marks = ['1', '1'];
    testDetails.resultsNockObj = resultsNock(true, execSubmissionObj);
    submitReqCheck(execSubmissionObj);
    testDetails.resultsVal = true;
    testAssertion(testDetails, [10], () => {
      done();
    });
  });
});

