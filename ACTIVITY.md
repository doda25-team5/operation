## WEEK 1&2 - Assignment 1 

#### Erkin : https://github.com/doda25-team5/app/pull/2, https://github.com/doda25-team5/app/pull/4, https://github.com/doda25-team5/app/pull/6, https://github.com/doda25-team5/model-service/pull/2, https://github.com/doda25-team5/model-service/pull/7.
Worked on Feature 3 and Feature 4, creating a Dockerfile and adding support for multiple architectures. However, while implementing Feature 3, I unintentionally did model training, which relates to Features 8 and 9, because I couldn’t get Feature 4 to work independently. For Feature 4, I uploaded the package to the registry and ran model training to verify that the multi-architecture images were functioning correctly. Additionally, there were issues accessing the lib-version packages, so I added a settings.xml file to the app repository and fixed the lib-version downloading problem.

#### Vedant: https://github.com/doda25-team5/app/pull/3, https://github.com/doda25-team5/model-service/pull/3
Worked on Feature 5 & 6 to enable multi-stage images for F5 and updated the Dockerfile to define model-service URL and service ports via environment variables, with app defaulting to 8080 and model-service to 8081.

#### Nicolas: https://github.com/doda25-team5/model-service/pull/4, https://github.com/doda25-team5/model-service/pull/8
Implemented Feature 9 by adding a Github Actions worklfow that automates model training and creates a Github release containing the generated model artifacts (the model, preprocessed_data and preprocessor joblib files).

#### Maja: https://github.com/doda25-team5/lib-version/actions/runs/19409393408, https://github.com/doda25-team5/lib-version/commit/70f6f248336be689bc5efeb0991d5b3e69b91447, https://github.com/doda25-team5/app/commit/96c0e769c29d73f96fb52ca15435d7ce793c9080
Implemented Feature 1 and 2. Due to the fact that those functionalities were the first ones, after I created the organization, I was committing to the main branch. On the next assignments I will be merging my features through PRs. For F1 I created a version-aware Maven library, made app depend on the library and created VersionUntil. Then I created a workflow for automatic packages and version lib-version to release it to Github package registry and added a version controller function in app. 

#### Jayran https://github.com/doda25-team5/app/pull/5, https://github.com/doda25-team5/model-service/pull/6, https://github.com/doda25-team5/lib-version/pull/2
Implemented F8 for both the app and model-service repositories, adding automated container image build-and-release workflows.
I also implemented F11 in the lib-version repository, adding automated stable releases, pre-releases, and version bumping.

#### Priyansh https://github.com/doda25-team5/operation/pull/1, https://github.com/doda25-team5/model-service/pull/5
Worked on Features 7 and 10. Set up the operation repo, cleaned up the Docker Compose setup, added .env support, linked the frontend and model-service images properly, and updated the configuration so everything runs smoothly together with the right environment variables.

## WEEK 3 - Assignment 2

#### Erkin : https://github.com/doda25-team5/operation/pull/6
Worked on the features 10 to 12 for the final project. Additionally in order to verify the step 12 worked, I had to add some initialization to the ctrl nodes to see if kubelet works. Additionally, each of us did the steps 1-12 on their which we decided as a team to learn better.

#### Vedant: https://github.com/doda25-team5/operation/pull/7
Worked on ctrl.yaml and node.yaml(steps 18-19). Implemented the worker-join logic so that each worker pulls the join command directly from the controller and only joins if it hasn’t already. I first check whether the worker has /etc/kubernetes/kubelet.conf; if not, I delegate the kubeadm token create --print-join-command call to the controller, capture the output, and then run that exact command on the worker to join the cluster safely and idempotently.

#### Nicolas: https://github.com/doda25-team5/operation/pull/5
Worked on general.yaml (steps 5-9), preparing all machines for Kubernetes. This included disabling swap, loading the br_netfilter and overlay kernel modules, enabling IPv4 and bridged packet forwarding via sysctl, managing host-to-IP mappings in /etc/hosts, and adding the official Kubernetes APT repository with its signing key so kubeadm, kubelet, and kubectl can be installed correctly.

#### Priyansh https://github.com/doda25-team5/operation/pull/4, https://github.com/doda25-team5/operation/pull/7
Worked on ctrl.yaml primarily (steps 13-17) i.e., initialized the Kubernetes cluster using kubeadm, configured kubectl access, installed the flannel Pod network with ```--iface=eth1``` for the correct NIC, and installed Helm along with the helm-diff plugin.

#### Maja https://github.com/doda25-team5/operation/pull/3
Implemented features 1-4 (steps). Created the VMs, set up the networking, provision with Ansible and registered the public SSH keys.

#### Jayran https://github.com/doda25-team5/operation/pull/8
In steps 20–22, I finalized the Kubernetes cluster by installing MetalLB, the Nginx Ingress Controller, and the Kubernetes Dashboard.
MetalLB was configured with a fixed IP range so LoadBalancer services receive stable external IPs (safe pool).
Next, I deployed the Nginx Ingress Controller via Helm and assigned it a fixed IP (192.168.56.90) for routing incoming traffic.
Finally, I installed the Kubernetes Dashboard using Helm, created an admin ServiceAccount with permissions, and exposed it through an Ingress at https://dashboard.local.


## WEEK 4 - Assignment 3

#### Erkin: 
Worked on the first part of the assignment migrating from docker-compose to kubernetes. Also worked on creating the helm charts and the directory. This is the branch https://github.com/doda25-team5/operation/tree/current that  i worked on and this is the pull request that we created as a group https://github.com/doda25-team5/operation/pull/10.

#### Nicolas
Worked on enabling the alerting capabilities in Prometheus so that developers get warned through email https://github.com/doda25-team5/operation/pull/10.

#### Maja:
Worked on the grafana dashboards to make them working https://github.com/doda25-team5/operation/pull/10. Also fixed the dashboard to make dashboard.local available that was the part that was missing from last week's assignment.

#### Jayran:
Worked on fixing the last week's assignment on dashboards. Also worked independently on migrating from docker-compose to kubernetes.

#### Vedant: https://github.com/doda25-team5/operation/pull/10, https://github.com/doda25-team5/app/pull/8, https://github.com/doda25-team5/model-service/pull/9
Worked on creating endpoints for app and model-service to enable monitoring and updated the deployement files to ensure prometheus can access those endpoints. 

#### Priyansh: https://github.com/doda25-team5/operation/pull/10, https://github.com/doda25-team5/app/pull/8, https://github.com/doda25-team5/model-service/pull/9
Worked independently on migration from docker to kubernetes and helm charts. Collaborated with Erkin and Jayran for this one. Then, I also worked on setting up grafana dashboards with Maja.

## WEEK 5 - Assignment 4
#### Erkin: https://github.com/doda25-team5/operation/pull/14
Worked on the assignment a4 adding virtual services, destination rules, gateways and having versioned deployments as v1 and v2. This was the first part of the assignment a4.

#### Jayran:https://github.com/doda25-team5/operation/pull/13 | https://github.com/doda25-team5/operation/pull/12
This week i went back to A2 to finish some off some things that we didn't do yet. I did the advanced step 8 where you dynamically add the hosts (by extra vars variable) and cleaned/updated the read me section for A2. For A3, I added the mount shared folder part. BUt Im not sure that it's correct since we used docker instead of virtualbox. This might need to be updated later but it works for docker currently. I also updateded the A3 part of the rubric detailing the work. No contributions to A4 a yet.

#### Nicolas: https://github.com/doda25-team5/operation/pull/15
Worked on fixing alerts from the last assignment and changed the approach by implementing gmail alerts.

#### Priyansh: https://github.com/doda25-team5/app/pull/10#
Spent my time adding metrics for the frontend without any external dependencies. Also currently working on making sure that gmail alerts work with Google app passcode (smtp) and are triggered by Prometheus monitoring the metric.

#### Vedant: https://github.com/doda25-team5/app/pull/10#
Spend a litle bit of my time in fixing the frontend metrics from last week and have also started implementing a the new feature for A4 where we are beautifying the frontend. The group has decided to create metrics to "test" the new version of the frontend which will be implemented by next week.

#### Maja https://github.com/doda25-team5/app/pull/10# https://github.com/doda25-team5/operation/pull/11
Worked on improving the app frontend metrics created by Priyansh. Then based on the new image implemented frontend metrings for two Grafana dashboards, making sure there was a sufficient variety between the types of plots and functions applied (avg and rate). 

## WEEK 6 - All Assignments

#### Erkin: https://github.com/doda25-team5/operation/pull/18
This week I worked on a4. Somehow, last week's merge overrode some files in the main branch so first i fixed it such that the helm chart can be executable. Also, our read me had missing steps for running the assignment a4 and alerts; therefore I fixed our readme. Finally, I make sure that the tags are right for the stable and canary releases for the front end and it complies the 90/10 rule.

#### Jayran: https://github.com/doda25-team5/operation/pull/17
I worked on A4 a little bit. The canary deployment and stable deployment were using the same backend and frontend images so i updated the values.yaml to ensure that each deployment have their own tags that they use for the images. For now they are still pointing to the same "latest" image but once we have our addition and create the tag for it, it will be updated.

#### Nicolas: 

#### Priyansh: https://github.com/doda25-team5/operation/pull/16
Finally managed to make alerts work - [Changed alerts so that they correspond to the frontend image instead of the backend image]. Made changes in the respective yaml templates in helm chart to accept release names on run time. Alerts now trigger and send mails properly when google-app-id is defined in secrets.

#### Vedant: https://github.com/doda25-team5/app/pull/11
Updated the frontend for our application (new feature). Need to set up specific metrics for tracking the implementation of the new feature. 

#### Maja: https://github.com/doda25-team5/operation/pull/19/
Worked on the A2 assignment this week, specifically setting up the step 23 for the final submission. The branch can be merged with the main with no conflicts but it needs further testing for veryfing if the everything works correctly. 

## Christmas Break
#### Priyansh: https://github.com/doda25-team5/operation/pull/20
Continued where Erkin left off, and managed to implement sticky sessions using Cookies to do so. Attempted rudimentary rate limiting and shadow launching, but will be picking one of the 2 to finally finalize on.

## WEEK 7 - All Assignments

#### Erkin:  https://github.com/doda25-team5/operation/pull/22
This week I confirmed what is working on a4 and what is not working there. I added some scripts in the readme to check if the implemented features are correct or not. In the dashboards some labels were contradicting the behaviour of the metrics; therefore i updated the metrics. Finally for alerts the mail time was taking to much; therefore i made it faster using a better parallelized script and i changed the rule for early triggering that is testable.

#### Jayran: https://github.com/doda25-team5/operation/pull/23
Worked on A4 for a bit. Started writing up the deployment documentation. Still have lots to write. 

#### Nicolas: https://github.com/doda25-team5/operation/pull/25
Worked on A4, specifically drafted the extension proposal section

#### Priyansh: https://github.com/doda25-team5/operation/pull/28
Worked on making values.yaml the single source of truth, finalized on Shadow Launching instead of rate limiting and modified how Shadow Launching works as compared to last week [Now we have a dedicated version (v3) of the model service that will receive copies of requests from both v1 and v2]

#### Vedant: https://github.com/doda25-team5/operation/pull/26, https://github.com/doda25-team5/operation/pull/21
Worked on assignment 2, specifically creating the jinja file and also working on step 23. The aim was to get assignment 2 closer to excellent criteria.

#### Maja: https://github.com/doda25-team5/operation/pull/27 https://github.com/doda25-team5/operation/pull/24 https://github.com/doda25-team5/model-service/pull/10
Worked on improving the A2 Readme for the final presentation. For A4 I improved the existing backend image for model versioning in model-service. Then in operation respository tried to display the metrics and their versions (v1-stable, v2-canary) by adding the prometheus metrics and using a new Grafana dashboard. These parts still needs testing.

## WEEK 8 - All Assignments

#### Erkin: https://github.com/doda25-team5/model-service/pull/11
This week i first try to install helm chart on the kubernetes cluster that we created in assignment 2 and managed to to it. Afterwards i looked at the all assignments and identified what was missing. Finally, i created a stable and pre release workflows for the model-service repository and fulfilled the missing criteria that we were missing.

#### Jayran: https://github.com/doda25-team5/operation/pull/31
Continued working on the deployment documentation. Made a sample deployment diagram but need to figure out how much more in depth i want to go also networking wise. 

#### Nicolas: https://github.com/doda25-team5/operation/pull/25
Continued with the work from last week and improved the extension proposal to fulfill the 'excellent' marks.

#### Priyansh: 

#### Vedant: https://github.com/doda25-team5/lib-version/pull/3
I worked on getting assignment 1 to excellent criteria by working on F11: Automatic versioning. Initially, our release and pre-release files were not configured correctly which has now been fixed. 

#### Maja: https://github.com/doda25-team5/operation/pull/29
This week I worked on beautifying A2 readme and making sure we fulfill the 'excellent' marks. inventory.cfg is created and updated as we run vagrant up to track the ansible hosts. I added regexp-based replacement in general.yaml and verified if its idempotent. Verified TLS certificate and key are provided (not auto-generated).
