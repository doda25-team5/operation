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

#### Vedant: https://github.com/doda25-team5/operation/pull/10
Worked on creating endpoints for app and model-service to enable monitoring and updated the deployement files to ensure prometheus can access those endpoints. 

#### Priyansh: https://github.com/doda25-team5/operation/pull/10
Worked independently on migration from docker to kubernetes and helm charts. Collaborated with Erkin and Jayran for this one. Then, I also worked on setting up grafana dashboards with Maja.
