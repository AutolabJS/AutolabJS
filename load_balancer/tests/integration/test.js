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
console.log('* TODO: correctly maintains the list of execution nodes during status check');
console.log('* TODO: correctly maintains the list of execution nodes during concurrent return of results');
console.log('* TODO: correctly maintains the list of execution nodes during errors in neighbouring components');
console.log('* TODO: ignores invalid messages from execution nodes');

console.log('* TODO: correctly handles results json with large logs of 50000 lines');
console.log('* TODO: verifies the authenticity of each execution node before adding it to the worker pool');
console.log('* TODO: verifies the origins of each evaluation result');

console.log('* TODO: Remains online and active when database is offline');
console.log('* TODO: Connects to database when database comes back online');

console.log('* TODO: Sets aside execution nodes that are offiline');
console.log('* TODO: incoming requests are distributed uniformly among all execution nodes');

console.log('* TODO: A user cancelled evaluation request is removed from job queue');
console.log('* TODO: Informs execution node about a cancelled job.');

console.log('* TODO: Accept requests / results only from authorized execution nodes');
console.log('* TODO: Uses a valid SSL certificate');
