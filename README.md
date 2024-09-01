# Von Heff Gallery - Application Infrastructure 

This repo creates app infrastructure supporting the hosting of the Von Herff Gallery application. It's one of three layers of infrastructure that needs to be built in AWS in order to host the Von Herff Gallery application.

## Prerequisite

Before building this infrastructure, make sure you've done any pre-work in order to get the Von Herff Gallery app hosted. Follow the instruction under the heading, [Run App Remotely in Production](https://github.com/beldenschroeder/vhg?tab=readme-ov-file#run-app-remotely-in-production-with-github-actions) of the _vhg_ repo's README.

This repo has a corresponding [Terraform workspace](https://developer.hashicorp.com/terraform/language/state/workspaces) with the same name. In the workspace is all the required configuration and environment variables to get this infrastructure build on AWS. The infrastructure gets created using GitHub Actions.

### Build the Infrastructure

Make any changes to this project needed. When you are ready, merge you feature branch into the _main_ branch. This will kick off a GitHub Action to provision the proper resources to AWS via the project's Terraform workspace.

Follow remaining tasks form [Run App Remotely in Production](https://github.com/beldenschroeder/vhg?tab=readme-ov-file#run-app-remotely-in-production-with-github-actions) of the _vhg_ repo's README, as mentioned in the [Prerequisite](#prerequisite) section.