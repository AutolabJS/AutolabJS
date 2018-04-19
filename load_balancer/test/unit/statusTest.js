/* eslint no-underscore-dangle: [2, { "allow": ["__get__"] }] */
/* eslint import/no-dynamic-require: 0 */
const chai = require('chai');
const { Status } = require('../../status.js');
const dirtyChai = require('dirty-chai');
const rewire = require('rewire');
const { check } = require('../../../util/environmentCheck.js');
const chaiAsPromised = require('chai-as-promised');

check('LBCONFIG');
const nodesData = require(`../../${process.env.LBCONFIG}`);
const getComponentStatus = rewire('../../status.js').__get__('getComponentStatus');
chai.should();
chai.use(dirtyChai);
chai.use(chaiAsPromised);

const incorrectNodes = [{
  role: 'execution_node',
  hostname: 'localhost',
  port: '8087',
},
{
  role: 'execution_node',
  hostname: 'localhost',
  port: '8088',
}];

let nodes;
let status;
describe('Method getComponentStatus returns expected objects', () => {
  let node;
  const checkComponentStatus = async function checkComponentStatus(enStatus) {
    const result = await getComponentStatus(node);
    result.should.have.all.keys('role', 'hostname', 'port', 'status');
    result.should.have.property('hostname', node.hostname);
    result.should.have.property('port', node.port);
    result.should.have.property('status', enStatus);
    result.should.have.property('role', 'execution_node');
  };

  it('An undefined object for an undefined node', async () => {
    getComponentStatus({}).should.be.rejectedWith('Invalid Node Configuration');
  });

  it('A correct JSON object for a working node', () => {
    node = nodesData.Nodes[0];
    return checkComponentStatus('up');
  });

  it('A correct JSON object for an incorrect node', () => {
    /* select a node that is not in the given configuration file */
    node = incorrectNodes[0];
    return checkComponentStatus('down');
  });
});

describe('Method getStatus returns correct status object', () => {
  const checkStatusObject = async function checkStatusObject(componentLength, enStatus) {
    status = new Status(nodes);
    const result = await status.checkStatus();
    result.should.exist();
    result.should.have.property('components');
    result.components.length.should.equal(componentLength);
    for (let i = 0; i < nodes.length; i += 1) {
      result.components[i].role.should.equal('execution_node');
      result.components[i].status.should.equal(enStatus);
    }
  };

  it('Empty object for empty input array of nodes', async () => {
    nodes = [];
    status = new Status(nodes);
    const response = await status.checkStatus();
    response.should.exist();
    response.should.have.property('components');
    response.components.should.be.an('array').that.is.empty();
  });

  it('Correct status object for input array of working nodes', () => {
    nodes = nodesData.Nodes;
    return checkStatusObject(Number(process.env.NUMBER_OF_EXECUTION_NODES), 'up');
  });

  it('Correct status for input array of nodes that dont exist', () => {
    nodes = incorrectNodes;
    return checkStatusObject(2, 'down');
  });
});

describe('Method selectActiveNodes returns expected array of nodes', () => {
  async function checkNodeQueue(nodeQueueLength) {
    status = new Status(nodes);
    const result = await status.selectActiveNodes();
    result.should.exist();
    result.should.be.an('array');
    result.length.should.equal(nodeQueueLength);
  }

  it('Empty array for empty input array of nodes', () => {
    nodes = [];
    return checkNodeQueue(0);
  });

  it('Correct array for an input array of working nodes', () => {
    nodes = nodesData.Nodes;
    return checkNodeQueue(Number(process.env.NUMBER_OF_EXECUTION_NODES));
  });

  it('Empty array for an input array of nodes that dont exist', () => {
    nodes = incorrectNodes;
    return checkNodeQueue(0);
  });
});
