const chai = require('chai');
const chaiAsPromised = require('chai-as-promised');
const dirtyChai = require('dirty-chai');
const { User, Project, listUsers } = require('../gitlab.js');
const { gitlab } = require('../../../deploy/configs/gitlab/gitlab.json');
const git = require('simple-git/promise');

chai.should();
chai.use(chaiAsPromised);
chai.use(dirtyChai);

const adminUserName = gitlab.username;
const gitlabHostname = gitlab.hostname;
const invalidUser = {
  username: 'incorrectUser',
  password: 'wrongPassword',
  project: 'project',
};
const testUser = {
  username: 'user',
  password: 'abcdefgh',
  project: 'project',
};

/* The environment variables used here are :
process.env.COMMITPATH is the path for the directory which contains the files to be committed
process.env.GITLABTEMP is the temp directory used for cloning during tests for commit */

let user;
let project;

/* This check tests if the listed users have the admin user listed since
admin user is the first user on gitlab. */

describe('List users on Gitlab', () => {
  it('List all existing users on Gitlab', async () => {
    const list = await listUsers();
    list.should.be.an('array').that.is.not.empty();
    list.should.include(adminUserName);
  });
});

describe('Add user to gitlab', () => {
  before(() => {
    user = new User(testUser.username, testUser.password);
  });

  it('Gitlab does not have the test user before addition', async () => {
    const list = await listUsers();
    list.should.be.an('array').that.does.not.include(testUser.username);
  });

  it('User is added correctly to Gitlab', async () => {
    const userDetails = await user.addUser();
    /* While registering for email, any upper case letter is converted to a
    lower case letter in gitlab */
    userDetails.should.have.property('email', `${testUser.username}@autolab.com`);
    userDetails.should.have.property('name', `${testUser.username}`);
    userDetails.should.have.property('username', `${testUser.username}`);
    userDetails.should.have.property('id');
    userDetails.should.have.property('confirmed_at');
  });

  it('Same user added twice will be rejected', async () => {
    const userDetails = await user.addUser();
    userDetails.should.not.have.any.keys('email', 'name', 'username', 'id', 'confirmed_at');
    userDetails.should.have.property('message', 'Email has already been taken');
  });
});

describe('Delete user on gitlab', () => {
  before(() => {
    user = new User(testUser.username, testUser.password);
  });

  it('Deleting an existing user is successful', async () => {
    const userDetails = await user.deleteUser();
    (typeof userDetails).should.equal('undefined');
  });

  it('Deleting a user that does not exist fails', async () => {
    const userDetails = await user.deleteUser();
    userDetails.should.have.property('error', '404 Not Found');
  });
});

describe('Create project for a user on gitlab', () => {
  user = new User(testUser.username, testUser.password);
  project = new Project(testUser.username, testUser.password, testUser.project);

  before(async () => {
    await user.addUser();
  });

  it('A new project for a user that does not exist will be rejected', async () => {
    const invalidProject = new Project(
      invalidUser.username,
      invalidUser.password,
      invalidUser.project,
    );
    invalidProject.createProject().should.be.rejectedWith('Error in obtaining a private token');
  });

  it('A new project is created successfully', async () => {
    const projectDetails = await project.createProject();
    projectDetails.should.have.property('http_url_to_repo', `https://${gitlabHostname}/${testUser.username}/${testUser.project}.git`);
    projectDetails.should.have.property('id');
    projectDetails.should.have.property('path_with_namespace', `${testUser.username}/${testUser.project}`);
  });

  it('Creating a project that exists will be rejected', async () => {
    const projectDetails = await project.createProject();
    projectDetails.should.have.property('message');
    (projectDetails.message).should.have.all.keys('limit_reached', 'name', 'path', 'route', 'route.path');
    (projectDetails.message.path).should.deep.equal(['has already been taken']);
    (projectDetails.message.route).should.deep.equal(['is invalid']);
  });

  after(() => user.deleteUser());
});

describe('Create a commit on Gitlab', () => {
  user = new User(testUser.username, testUser.password);
  project = new Project(testUser.username, testUser.password, testUser.project);
  const projectUrl = `https://${testUser.username}:${testUser.password}@${gitlabHostname}/${testUser.username}/${testUser.project}.git`;

  async function getCommitHash() {
    let simpleGit = git(process.env.GITLABTEMP);
    let logData;
    try {
      await simpleGit.clone(projectUrl);
      simpleGit = git(`${process.env.GITLABTEMP}/${testUser.project}`);
      logData = await simpleGit.log();
    } catch (error) {
      throw new Error('Error in obtaining commit hash');
    }
    return logData.latest.hash;
  }

  before(async () => {
    try {
      await user.addUser();
      await project.createProject();
    } catch (error) {
      throw new Error('User/Project creation failed before commit');
    }
  });

  it('Files at the specified path are committed to a project', async () => {
    const commitDetails = await project.commit(process.env.COMMITPATH);
    commitDetails.should.have.property('branch', 'master');
    commitDetails.should.have.property('summary').that.includes.all.keys(['changes', 'insertions', 'deletions']);
    (commitDetails.summary.changes).should.equal('2');
    (commitDetails.summary.insertions).should.equal('64');
    (commitDetails.summary.deletions).should.equal(0);
    const logData = await getCommitHash();
    (logData.slice(0, 7)).should.equal(commitDetails.commit.slice(-7));
  });

  after(() => user.deleteUser());
});
