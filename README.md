# Define ArgoCD projects and their apps (non-prod)

## What is this?

Repo for management of Argo projects and apps for non-prod environments.



This repo consists of Helm resource definitions that allow us to on-board/off-board projects, applications and what environments (clusters) those applications are deployed to.

## How do I on-board/off-board applications/projects?

* Create a branch named something like `eks-1234`. It should have the Jira ticket related to onboarding the team/application
* Modify [projects-and-apps/values.yaml](projects-and-apps/values.yaml) , hopefully the format of this is self-explanatory, see section below for more advice.
* Run `helm template projects-and-apps` and make sure it works and does what you want
* Commit and push to the branch
* Create a pull request
* A diff will be auto created and added as a comment to assist with review
* Get the PR reviewed/check the output of the helm template run. 

* After review, merge!
* ArgoCD will update the projects and applications
* Delete the feature branch, after confirming that the changes work in Argo, so we don't end up with hundreds of branches lying around!

Note: By default if you do not specify a `namespaceOverride` for an application then it will go into a namespace named the same as the `projects` `name`. This means if you have multiple applications under a project they will by default go into a single namespace.

## Editing `values.yaml`

In general just copy and paste an existing application/project.


You should only specify environments for the application that an application is actually onboarded to. e.g. you have `project1` with two applications `application1` and `application2`. 
* `application1` is onboarded to `dev`
* `application2` is onboarded to `dev` `qal` `pte`

From this the configuration for this project should look something like:
```yaml
- name: "project1"
  description: "Project 1 description"
  applications:
  - name: "app1"
    repoURL: "https://github.com/ake13/app1.git"
    environments:
    - name: dev
  - name: "project2"
    repoURL: "https://github.com/ake13/app2.git"
    environments:
    - name: dev
    - name: qal
    - name: pte
```


That can be done via configuration like this:

```yaml
- name: "my-project"
  dynatraceEnvs:
  - dev
  - pte
  description: "Project for Me"
  applications:
  - ...
```

You will still need to use annotations on your workloads in addition to this change.

## Ignoring Differences

Sometimes, it is sometimes (but rarely) useful to not have argo mark a difference as out of sync.  Argo provides a way to do that
by way of the [Ignore Differences Configuration](https://argoproj.github.io/argo-cd/user-guide/diffing/#application-level-configuration).
You can set this up by adding an `ignoreDifferences` property at the application level of your config.

example:

```yaml
- name: "my-project"
  description: "Project for Me"
  applications:
  - name: "my-application"
    ignoreDifferences:
    - group: apps
      kind: Deployment
      name: guestbook
      namespace: default
      jsonPointers:
      - /spec/replicas
```

The `jqPathExpresions` syntax given in the argo documentation will also work if a more complicated ignore is needed.

## How can I see the resources that Argo will deploy?

Try cloning this repo and running:

```bash
cd dbk-sre-argocd-nonprod-apps
# Build app and project resources for all projects
helm template projects-and-apps
```
