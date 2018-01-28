const request = require('request-promise-native');
const simpleGit = require('simple-git/promise')();
const { gitlab } = require('../../deploy/configs/gitlab/gitlab.json');

const adminUserName = gitlab.username;
const adminPassword = gitlab.password;
const gitlabHostname = gitlab.hostname;
const gitlabApiUrl = `https://${gitlabHostname}/api/v4/`;

async function gitlabAPICaller(httpMethod, resource, requestBody) {
  let responseBody;
  try {
    responseBody = await request[httpMethod](`${gitlabApiUrl}${resource}`, requestBody);
  } catch (error) {
    return [responseBody, error];
  }
  return [responseBody, null];
}

async function getToken(user = adminUserName, pass = adminPassword) {
  const requestBody = {
    json: {
      login: user,
      password: pass,
    },
  };
  const [responseBody, error] = await gitlabAPICaller('post', 'session/', requestBody);
  if (error != null) {
    throw new Error('Error in obtaining a private token');
  }
  return responseBody.private_token;
}

async function getId(userName) {
  const authToken = await getToken();
  const [responseBody, error] = await gitlabAPICaller('get', `users?private_token=${authToken}`);
  if (error != null) {
    throw new Error(`Error in obtaining ID of user ${userName}`);
  }
  const entries = Array.from(JSON.parse(responseBody));
  const userEntry = await entries.find(entry => entry.username === userName);
  const userId = (userEntry) ? userEntry.id : -1;
  return [authToken, userId];
}

async function listUsers() {
  const authToken = await getToken();
  const [responseBody, error] = await gitlabAPICaller('get', `users?private_token=${authToken}`);
  if (error != null) {
    throw new Error('Error in listing users');
  }
  const usernames = (JSON.parse(responseBody)).map(entry => entry.username);
  return usernames;
}

class User {
  constructor(username, password, email) {
    /* Default password if set to 12345678 */
    this.username = username;
    this.password = password || 12345678;
    this.email = email || `${this.username}@autolab.com`;
  }

  async addUser() {
    const emailId = this.email;
    const requestBody = {
      json: {
        name: this.username,
        username: this.username,
        password: this.password,
        email: emailId,
        skip_confirmation: true,
      },
    };
    const authToken = await getToken();
    const response = await gitlabAPICaller('post', `users?private_token=${authToken}`, requestBody);
    const error = response[1];
    const responseBody = (error) ? error.error : response[0];

    if (error != null && error.message !== '409 - {"message":"Email has already been taken"}') {
      throw new Error(`Error in adding user ${this.username}`);
    }
    return responseBody;
  }

  async deleteUser() {
    const [authToken, userId] = await getId(this.username);
    const requestBody = {
      json: {
        id: userId,
        hard_delete: true,
      },
    };
    const response = await gitlabAPICaller('delete', `users/${userId}?private_token=${authToken}`, requestBody);
    const error = response[1];
    const responseBody = (error) ? error.error : response[0];

    if (error != null && error.message !== '404 - {"error":"404 Not Found"}') {
      throw new Error(`Error in deleting user ${this.username}`);
    }
    return responseBody;
  }
}

class Project {
  constructor(username, password, projectName) {
    this.username = username;
    this.password = password || 12345678;
    this.projectName = projectName;
  }

  async createProject() {
    const requestBody = {
      json: {
        name: this.projectName,
      },
    };
    const authToken = await getToken(this.username, this.password);
    const response = await gitlabAPICaller('post', `projects?private_token=${authToken}`, requestBody);
    const error = response[1];
    const responseBody = (error) ? error.error : response[0];

    if (error != null && (!(error.message).includes('400 - {"message":{"route.path":["has already been taken"]'))) {
      throw new Error(`Error in creating project ${this.projectName} for user ${this.username}`);
    }
    return responseBody;
  }

  async commit(commitFilesPath) {
    const projectPath = `https://${this.username}:${this.password}@${gitlabHostname}/${this.username}/${this.projectName}.git`;
    let commitDetails;
    try {
      await simpleGit.cwd(commitFilesPath);
      await simpleGit.init();
      await simpleGit.add(`${commitFilesPath}/*`);
      commitDetails = await simpleGit.commit('first commit!');
      await simpleGit.addRemote('origin', projectPath);
      await simpleGit.push('origin', 'master');
    } catch (error) {
      throw new Error('Commit failed');
    }
    return commitDetails;
  }
}

module.exports = {
  User,
  Project,
  listUsers,
};
