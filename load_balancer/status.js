/* eslint import/no-dynamic-require: 0 */
const { Logger } = require('../util/logger.js');
const { check } = require('../util/environmentCheck.js');
const request = require('request-promise-native');

/* The environment variable LBCONFIG will contain the path to the config file.
  The actual path for the config is "../deploy/configs/load_balancer/nodes_data_conf.json"
  For the docker containers, the path is /etc/load_balancer/nodes_data_conf.json */
check('LBCONFIG');

const lbConfig = require(process.env.LBCONFIG);

const loggerConfig = lbConfig.load_balancer;
loggerConfig.cmd = 'log';

const logger = new Logger(loggerConfig);

const isValidNode = function isValidNode(node) {
  const hostname = node.hostname;
  const port = node.port;
  const role = node.role;
  if (hostname === undefined || port === undefined || role === undefined) {
    return false;
  }
  return true;
};

async function getComponentStatus(node) {
  if (!isValidNode(node)) {
    throw new Error('Invalid Node Configuration');
  }

  const resultJson = Object.assign({}, node);
  try {
    const body = await request.get(`https://${node.hostname}:${node.port}/connectionCheck`);
    if (body.toString() === 'true') {
      logger.debug(`Node at ${node.hostname}:${node.port} is up and running.`);
      resultJson.status = 'up';
    }
  } catch (err) {
    logger.error(`Error connecting to ${node.hostname}:${node.port}`);
    logger.error(err);
    resultJson.status = 'down';
  }
  return resultJson;
}

async function getAllComponentsResponse(nodes) {
  const promises = [];
  for (let i = 0; i < nodes.length; i += 1) {
    promises.push(getComponentStatus(nodes[i]));
  }
  return promises;
}

class Status {
  constructor(nodes) {
    this.nodes = nodes;
  }

  async selectActiveNodes() {
    const nodeQueue = [];
    // Check connection of all nodes
    const data = await Promise.all(await getAllComponentsResponse(this.nodes));
    for (let i = 0; i < data.length; i += 1) {
      if (data[i].status === 'up') {
        nodeQueue.push({
          hostname: data[i].hostname,
          port: data[i].port,
        });
        logger.debug(`Added node ${data[i].hostname}:${data[i].port} to the node queue.`);
      }
    }
    return nodeQueue;
  }
  async checkStatus() {
    const result = {};
    result.components = [];
    result.components = await Promise.all(await getAllComponentsResponse(this.nodes));
    return result;
  }
}

module.exports = {
  Status,
};
