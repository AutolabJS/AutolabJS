console.log('======integration tests on load balancer======\n');
/*
best choices for E2E automation testing are:
      cucumber.js - for requirements testing
      mocha.js    - for unit testing
      chai.js     - for assertions
      sinon.js    - for test doubles
      nightmare.js - for headless browser-based testing;
                     to be used with mocha and chai for functional tests
      nightwatch.js - high-level selenium-driver with own assertions;
                      easy to use; to be used with mocha for functional tests
      webdriverIO.js - low-level, but sensible selenium-driver which has to be used with
                      mocha and chai for functional tests
*/

const chai = require('chai');
const dirtyChai = require('dirty-chai');
const request = require('request');
const nock = require('nock');
const dns = require('dns');
const sinon = require('sinon');
const rewire = require('rewire');
const { check } = require('../../../util/environmentCheck.js');
const { Status } = require('../../status.js');
const testData = require('./data/submission.json');
const nodes_data = require(`../../${process.env.LBCONFIG}`);
const lbUrl = `https://${nodes_data.load_balancer.hostname}:${nodes_data.load_balancer.port}`;
const sandbox = sinon.createSandbox();

let loadBalancer;
let logStub;

// eslint-disable-next-line import/no-dynamic-require
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
  loadBalancer = rewire('../../load_balancer.js');
};

// console.log('* TODO: correctly maintains the list of execution nodes during status check');
// console.log('* TODO: correctly maintains the list of execution nodes during concurrent return of results');
// console.log('* TODO: correctly maintains the list of execution nodes during errors in neighbouring components');
// console.log('* TODO: ignores invalid messages from execution nodes');

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
    const res = JSON.parse(JSON.stringify(nodes_data.Nodes));
    const lbTestStatus = nodes_data.load_balancer;
    lbTestStatus.status = 'up';
    for (var i = 0; i <= 1; i++) {
      nock(`https://${res[i].hostname}:${res[i].port}`)
        .persist()
        .get('/connectionCheck')
        .reply(200, (uri, requestBody) => {
          return true;
        });
    }
    request.get(`${lbUrl}/connectionCheck`, (error, response) => {
      const responseBody = JSON.parse(response.body);
      response.should.exist();
      responseBody.should.have.all.keys('components', 'job_queue_length', 'timestamp');
      responseBody.job_queue_length.should.equal(loadBalancer.job_queue.length);
      responseBody.timestamp.should.be.a('string');
      responseBody.components.should.be.an('array');
      responseBody.components.should.deep.include(lbTestStatus);
      responseBody.components.forEach((elem, index) => {
        if(index === 0 || index === 1 || index === 10)
          elem.status.should.equal('up');
        else
          elem.status.should.equal('down');
      });
      restoreConsole();
      done();
    });
  });
});

// console.log('* TODO: correctly handles results json with large logs of 50000 lines');
// console.log('* TODO: verifies the authenticity of each execution node before adding it to the worker pool');
// console.log('* TODO: verifies the origins of each evaluation result');
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

  it('when no job is pending', (done) => {
    stubConsole();
    const tempNode = testData.nodesData[0];
    var requestRunNock = nock(`https://${tempNode.hostname}:${tempNode.port}`)
      .persist()
      .post('/requestRun')
      .reply(200, (uri, requestBody) => {
        requestBody.should.have.all.keys('id_no', 'Lab_No', 'time', 'commit', 'status', 'penalty', 'socket', 'language');
        requestBody.should.deep.equal(tempJob);
        return true;
      });
    nock(`https://${tempNode.hostname}:${tempNode.port}`)
      .get('/connectionCheck')
      .reply(200, (uri, requestBody) => {
        return false;
      });
    let connectionCheckNock = nock(`https://${tempNode.hostname}:${tempNode.port}`)
      .get('/connectionCheck')
      .reply(200, (uri, requestBody) => {
        return true;
      });
    request.post(`${lbUrl}/addNode`, { json: tempNode });
    request.get(`${lbUrl}/connectionCheck`, (error, response) => {
      const responseBody = JSON.parse(response.body);
      responseBody.components.forEach((elem, index) => {
        if(index === 0 || index === 10)
          elem.status.should.equal('up');
        else
          elem.status.should.equal('down');
      });
      requestRunNock.isDone().should.equal(false);
      restoreConsole();
      done();
    });
  });

  it('when a job is pending', (done) => {
    stubConsole();
    const tempNode = testData.nodesData[0];
    const tempJob = testData.submissionsData[0];
    nock(`https://${tempNode.hostname}:${tempNode.port}`)
      .get('/connectionCheck')
      .reply(200, (uri, requestBody) => {
        return false;
      });
    nock(`https://${tempNode.hostname}:${tempNode.port}`)
      .get('/connectionCheck')
      .reply(200, (uri, requestBody) => {
        return true;
      });
    var requestRunNock = nock(`https://${tempNode.hostname}:${tempNode.port}`)
      .persist()
      .post('/requestRun')
      .reply(200, (uri, requestBody) => {
        requestBody.should.have.all.keys('id_no', 'Lab_No', 'time', 'commit', 'status', 'penalty', 'socket', 'language');
        requestBody.should.deep.equal(tempJob);
        return true;
      });
    request.post(`${lbUrl}/submit`, { json: tempJob}, (error, response) => {
      (error === null).should.be.true;
      response.body.should.equal(true);
    });
    request.post(`${lbUrl}/addNode`, { json: tempNode });
    request.get(`${lbUrl}/connectionCheck`, (error, response) => {
      const responseBody = JSON.parse(response.body);
      responseBody.components.forEach((elem, index) => {
        if(index === 0 || index === 10)
          elem.status.should.equal('up');
        else
          elem.status.should.equal('down');
      });
      requestRunNock.isDone().should.equal(true);
      restoreConsole();
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
    request.post(`${lbUrl}/submit`, { json: tempJob}, (error, response) => {
      (error === null).should.be.true;
      response.body.should.equal(true);
    });
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
    const tempJob = testData.submissionsData[0];
    request.post(`${lbUrl}/submit`, { json: tempJob}, (error, response) => {
      (error === null).should.be.true;
      response.body.should.equal(true);
    });
    request.get(`${lbUrl}/connectionCheck`, (error, response) => {
      const responseBody = JSON.parse(response.body);
      responseBody.components.forEach((elem, index) => {
        if (index === 10)
          elem.status.should.equal('up');
        else
          elem.status.should.equal('down');
      });
      restoreConsole();
      done();
    });
  });

  it('when node is available to process request', (done) => {

    stubConsole();
    const tempNode = testData.nodesData[0];
    const tempJob = testData.submissionsData[0];
    nock(`https://${tempNode.hostname}:${tempNode.port}`)
      .persist()
      .get('/connectionCheck')
      .reply(200, (uri, requestBody) => {
        return true;
      });
    var requestRunNock = nock(`https://${tempNode.hostname}:${tempNode.port}`)
      .persist()
      .post('/requestRun')
      .reply(200, (uri, requestBody) => {
        requestBody.should.have.all.keys('id_no', 'Lab_No', 'time', 'commit', 'status', 'penalty', 'socket', 'language');
        requestBody.should.deep.equal(tempJob);
        return true;
      });
    request.post(`${lbUrl}/submit`, { json: tempJob}, (error, response) => {
      (error === null).should.be.true;
      response.body.should.equal(true);
    });
    request.get(`${lbUrl}/connectionCheck`, (error, response) => {
      const responseBody = JSON.parse(response.body);
      responseBody.components.forEach((elem, index) => {
        if(index === 0 || index === 10)
          elem.status.should.equal('up');
        else
          elem.status.should.equal('down');
      });
      requestRunNock.isDone().should.equal(true);
      restoreConsole();
      done();
    });
  });
});

// console.log('* TODO: Remains online and active when database is offline');
// console.log('* TODO: Connects to database when database comes back online');

// console.log('* TODO: Sets aside execution nodes that are offiline');
// console.log('* TODO: incoming requests are distributed uniformly among all execution nodes');

// console.log('* TODO: A user cancelled evaluation request is removed from job queue');
// console.log('* TODO: Informs execution node about a cancelled job.');

// console.log('* TODO: Accept requests / results only from authorized execution nodes');
// console.log('* TODO: Uses a valid SSL certificate');
