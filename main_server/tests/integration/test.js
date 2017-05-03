console.log('======integration tests on mainserver======\n');

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
console.log('* TODO: website loads successfully');
console.log('* TODO: all hyperlinks on the page work\n');
console.log('* TODO: Able click on submit button to open the submission form (for one lab)');
console.log('* TODO: Able to click on scoreboard to open scoreboard (for one lab)');
console.log('* TODO: Able click on submit button to open the submission form (for many labs)');
console.log('* TODO: Able to click on scoreboard button to open the submission form (for many labs)');
console.log('* TODO: Able to make one submission for one student (for one lab)');
console.log('* TODO: Able to make one submission with known hash for one student (for one lab)');
console.log('* TODO: Submission with unknown hash gives predictable response');
console.log('* TODO: Able to make multiple submissions for one student (for one lab)');
console.log('* TODO: Able to make one submission for one student (for multiple labs)');
console.log('* TODO: Able to make multiple submissions for one student (for multiple labs)');
console.log('* TODO: same code submitted by multiple students receives same marks\n');
console.log('* TODO: /status page loads successfully and contains correct information');
console.log('* TODO: /admin page loads successfully');
console.log('* TODO: successful login to admin page');
console.log('* TODO: successful addition of new lab using /admin-->configure page');
console.log('* TODO: Lab changes made on /admin-->configure page are reflected on the main page for one lab');
console.log('* TODO: successful addition of multiple new labs using /admin-->configure page');
console.log('* TODO: Lab changes made on /admin-->configure page are reflected on the main page for multiple labs');
console.log('* TODO: successful logout of admin page');
console.log('* TODO: No unauthorized access to /admin page');

console.log('* TODO: Main server gives reasonable response when load balancer is offline');
console.log('* TODO: Main server gives reasonable response when load balancer does not return an evaluation result');
console.log('* TODO: Main server gives reasonable response when load balancer gives invalid json object');
console.log('* TODO: Main server gives reasonable response when database is offline');

console.log('* TODO: Main server remains online when database is offline');
console.log('* TODO: Main server connects to database when database comes back online');

console.log('* TODO: scoreboard is displayed correctly for 10 entries');
console.log('* TODO: scoreboard is displayed correctly for 100 entries');
console.log('* TODO: scoreboard is displayed correctly for 1000 entries');
console.log('* TODO: scoreboard is displayed correctly for 10000 entries');

console.log('* TODO: Main server follows timeout evaluation instruction from load balancer');
console.log('* TODO: Main server correctly returns an evaluation result null log');
console.log('* TODO: Main server correctly returns an evaluation result non-null log');
console.log('* TODO: Main server correctly returns an evaluation result with special characters in log');
console.log('* TODO: Main server correctly returns an evaluation result with 100 lines of log');
console.log('* TODO: Main server correctly returns an evaluation result with 1000 lines of log');
console.log('* TODO: Main server correctly returns an evaluation result with 10000 lines of log');
console.log('* TODO: Main server correctly returns an evaluation result with 50000 lines of log');

console.log('* TODO: User can cancel a pending evaluation request');
console.log('* TODO: Can handle upto a million requests without any memory leak');

console.log('* TODO: Uses a valid SSL certificate');
