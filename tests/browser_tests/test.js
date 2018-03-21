console.log('======end to end functional tests to be developed using nightmare.js======\n');

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

console.log('* TODO: repeat all tests of unit-tests.bats');
console.log('* TODO: repeat all tests of io-tests.bats\n');

console.log('* TODO: submission with special characters in code gives unsuccessful evaluation');
console.log('* TODO: submission with empty student code gives unsuccessful evaluation');
console.log('* TODO: submission with empty instructor code gives sensible return message\n');
