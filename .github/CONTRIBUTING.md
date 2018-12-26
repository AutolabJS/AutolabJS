# How to contribute

Thank you for contributing to AutolabJS.

This project uses a "fork and pull" model for collaborative software development. From the [GitHub Help Page of Using Pull Requests](https://help.github.com/articles/using-pull-requests/):

> "The fork & pull model lets anyone fork an existing repository and push changes to their personal fork without requiring access be granted to the source repository. The changes must then be pulled into the source repository by the project maintainer. This model reduces the amount of friction for new contributors and is popular with open source projects because it allows people to work independently without upfront coordination."

## Branches
AutolabJS currently maintains two branche(s):
* **master**:  this is the stable branch to be used for installation.
* **dev**: all of the development happens on dev and is periodically merged with master.

## Code style guidelines
The [style guidelines](https://github.com/AutolabJS/AutolabJS/wiki/Coding-Standards) wiki page defines the source file coding standards used in this project.

The following case convention is used in this project: module_name, package_name, ClassName, methodName, ExceptionName, functionName, GLOBAL_CONSTANT_NAME, global_var_name, instance_var_name, function_parameter_name, local_var_name.

## Submitting pull requests
* Always check out the `dev` branch and submit pull requests against it.
* Maintain a clean commit history even during review. That means that commits are rebased and squashed if necessary, so that each commit clearly contains one change and there are no extraneous fix-ups.
* The pull request should be motivated, i.e. what does it fix, why, and if relevant how.
* If possible, include an example in the description, that could help all readers (including project members) to get a better picture of the change.
* Avoid other runtime dependencies unless abslutely necessary
* Ensure that your pull request follows the [style guidelines](https://github.com/AutolabJS/AutolabJS/wiki/Coding-Standards)
* At least one commit should mention `Fixes #<issue number>`.


## Automated testing on Travis CI
All Pull Requests are automatically tested on [TravisCI](https://travis-ci.org/AutolabJS/AutolabJS).

## Additional Resources
* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
