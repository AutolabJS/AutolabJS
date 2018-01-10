const argv = require('minimist')(process.argv.slice(2));
const request = require('request-promise-native');
const simpleGit = require('simple-git/promise')();
const { gitlab } = require('../../deploy/configs/gitlab/gitlab.json');

const adminUserName = gitlab.username;
const adminPassword = gitlab.password;
const gitlabHostname = gitlab.hostname;

async function getToken(user = adminUserName, pass = adminPassword) {
  let body;
  try {
    body = await request.post(`https://${gitlabHostname}/api/v4/session/`, { json: { login: user, password: pass } });
  } catch (error) {
    throw new Error('Error in obtaining a private token');
  }
  return body.private_token;
}

async function getId(userName) {
  let userId = -1;
  try {
    const token = await getToken();
    const body = await request.get(`https://${gitlabHostname}/api/v4/users?private_token=${token}`);
    const entries = Array.from(JSON.parse(body));
    for (let i = 0; i < entries.length; i += 1) {
      if (entries[i].username === userName) {
        userId = entries[i].id;
      }
    }
  } catch (error) {
    // this error will happen when the https call to gitlab fails
    throw new Error(`Error in obtaining ID of user ${userName}`);
  }
  return userId;
}

async function listUsers() {
  let usernames = [];
  try {
    const token = await getToken();
    const body = await request.get(`https://${gitlabHostname}/api/v4/users?private_token=${token}`);
    usernames = (JSON.parse(body)).map(entry => entry.username);
  } catch (error) {
    // this error will happen when the https call to gitlab fails
    throw new Error('Error in listing users');
  }
  return usernames;
}

class User {
  constructor(username, password) {
    /* Default password if set to 12345678 */
    this.username = username;
    this.password = password || 12345678;
  }

  async addUser() {
    const emailId = `${this.username}@autolab.com`;
    let body = {};
    try {
      const token = await getToken();
      body = await request.post(`https://${gitlabHostname}/api/v4/users?private_token=${token}`, {
        json: {
          name: this.username,
          username: this.username,
          password: this.password,
          email: emailId,
          skip_confirmation: true,
        },
      });
    } catch (error) {
      body = error.error;
      if (error.message !== '409 - {"message":"Email has already been taken"}') {
        throw new Error(`Error in adding user ${this.username}`);
      }
    }
    return body;
  }

  async deleteUser() {
    let body;
    try {
      const token = await getToken();
      const userId = await getId(this.username);
      body = await request.delete(`https://${gitlabHostname}/api/v4/users/${userId}?private_token=${token}`, { json: { id: userId, hard_delete: true } });
    } catch (error) {
      body = error.error;
      if (error.message !== '404 - {"error":"404 Not Found"}') {
        throw new Error(`Error in deleting user ${this.username}`);
      }
    }
    return body;
  }
}

class Project {
  constructor(username, password, projectName) {
    this.username = username;
    this.password = password || 12345678;
    this.projectName = projectName;
  }

  async createProject() {
    let body;
    try {
      const token = await getToken(this.username, this.password);
      body = await request.post(`https://${gitlabHostname}/api/v4/projects?private_token=${token}`, { json: { name: this.projectName } });
    } catch (error) {
      body = error.error;
      if ((!(error.message).includes('400 - {"message":{"route.path":["has already been taken"]'))) {
        throw new Error(`Error in creating project ${this.projectName} for user ${this.username}`);
      }
    }
    return body;
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


/*
The options allowed are:

-f : Function to perform. Valid values are add, delete, list, create, commit
--user : User Name
--pro : Project Name
--pass : Password
--path : Path for the directory which contains files to be commited to gitlab
         in the specified project. This should not be a git directory.
*/

async function gitAction() {
  const user = new User(argv.user, argv.pass);
  const project = new Project(argv.user, argv.pass, argv.pro);
  let userList;
  switch (argv.f) {
    case 'add':
      if (argv.user) {
        await user.addUser();
      } else {
        console.log('Specify correct parameters : User Name (required), Password (optional, default value: 12345678)');
      }
      break;
    case 'delete':
      if (argv.user) {
        await user.deleteUser();
      } else {
        console.log('Specify correct parameters : User Name (required)');
      }
      break;
    case 'list':
      userList = await listUsers();
      console.log(userList);
      break;
    case 'create':
      if (argv.user && argv.pro) {
        await project.createProject();
      } else {
        console.log('Specify correct parameters : User Name (required), Password (optional, default value: 12345678), Project Name (required)');
      }
      break;
    case 'commit':
      if (argv.user && argv.pro && argv.path) {
        await project.commit(argv.path);
      } else {
        console.log('Specify correct parameters : User Name (required), Password (optional, default value: 12345678), Project Name (required), Path for the files to be commited (required)');
      }
      break;
    default: console.log('Invalid function specified. Valid functions are: add, delete, list');
  }
}

if (argv.f) {
  gitAction().catch((error) => {
    console.log('The specified action could not be performed.');
    console.log(error);
  });
} else {
  console.log('No function specified. Valid functions are: add, delete, list');
}

module.exports = {
  User,
  Project,
  listUsers,
};
