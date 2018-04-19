const chai = require('chai');
const envCheck = require('../../environmentCheck.js');

chai.should();
process.env.validFile = './package.json';

describe('Check function works correctly', () => {
  it('Checks response for null variable', () => {
    (envCheck.check.bind(envCheck, '')).should.throw(Error, 'Path to config file is not specified.');
  });

  it('Checks valid environment variable', () => {
    (envCheck.check.bind(envCheck, 'validFile')).should.not.throw(Error);
  });
});
