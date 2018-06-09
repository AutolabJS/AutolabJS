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
const sinon = require('sinon');
const rewire = require('rewire');
const proxyquire = require('proxyquire');
const { check } = require('../../../util/environmentCheck.js');
const { Status } = require('../../status.js')

check('LBCONFIG');
// eslint-disable-next-line import/no-dynamic-require
const nodes_data = require(`../../${process.env.LBCONFIG}`);
const lbUrl = `https://${nodes_data.load_balancer.hostname}:${nodes_data.load_balancer.port}`;
chai.should();
chai.use(dirtyChai);
let loadBalancer;
let testStatus;
var job_queue;
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
    //activateNocks();
  });

  afterEach((done) => {
    //cleanNocks();
    loadBalancer.server.close(done);
  });

  it('during status check', (done) => {
    stubConsole();
    testStatus = new Status(nodes_data.Nodes);
    //proxyquire('./../../load_balancer.js', { 'status': testStatus});
    loadBalancer.__set__('status',testStatus);    
    sandbox.stub(testStatus, 'checkStatus').callsFake(() => {
      var result = {};
      result.components = JSON.parse(JSON.stringify(nodes_data.Nodes));
      result.components.forEach((elem) => {
        elem.status = "down";
      });
      return result;
    });
    let lbTestStatus = nodes_data.load_balancer;
    lbTestStatus.status = "up";    
    request.get(`${lbUrl}/connectionCheck`, (error, response) => { 
      let responseBody = JSON.parse(response.body);
      response.should.exist();
      responseBody.should.have.all.keys("components","job_queue_length","timestamp");
      responseBody.job_queue_length.should.equal(loadBalancer.job_queue.length);
      responseBody.timestamp.should.be.a('string');
      responseBody.components.should.be.an('array');
      responseBody.components.should.deep.include(lbTestStatus);
      restoreConsole();
      done();
    });
  });
});

// console.log('* TODO: correctly handles results json with large logs of 50000 lines');
// console.log('* TODO: verifies the authenticity of each execution node before adding it to the worker pool');
// console.log('* TODO: verifies the origins of each evaluation result');
describe('Verifies', () => {

  beforeEach(() => {
    stubConsole();
    startLoadBalancer();
    restoreConsole();
    //activateNocks();
  });

  afterEach((done) => {
    //cleanNocks();
    loadBalancer.server.close(done);
  });

  it('when new EN sends addNode request', (done) => {
    stubConsole();
    let testNode = nodes_data.Nodes[0];
    loadBalancer.__set__('job_queue', []);
    loadBalancer.__set__('node_queue', []);
    request.post(`${lbUrl}/addNode`, { json: testNode }, (error,response) => {
      (error === null).should.be.true();
      response.body.should.equal(true);
      //sinon.assert.calledThrice(logStub);
      loadBalancer.node_queue = loadBalancer.__get__('node_queue');
      loadBalancer.node_queue.should.be.an('array').that.deep.includes(testNode);
      restoreConsole();
      done();
    });
  });

  it('when already added EN sends addNode request', (done) => {
    //stubConsole();
    let testNode = nodes_data.Nodes[0];
    loadBalancer.__set__('job_queue', []);
    loadBalancer.__set__('node_queue', [testNode]);
    console.log(loadBalancer.__get__('node_queue'));
    request.post(`${lbUrl}/addNode`, { json: testNode }, (error,response) => {
      (error === null).should.be.true();
      response.body.should.equal(true);
      //sinon.assert.calledOnce(logStub);
      loadBalancer.node_queue = loadBalancer.__get__('node_queue');
      loadBalancer.node_queue.should.be.an('array').that.deep.includes(testNode);
      //restoreConsole();
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
