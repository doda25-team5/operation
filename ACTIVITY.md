## WEEK 1&2 - Assignment 1 

#### Erkin : 

#### Vedant: https://github.com/doda25-team5/app/pull/3, https://github.com/doda25-team5/model-service/pull/3
Worked on Feature 5 & 6 to enable multi-stage images for F5 and updated the Dockerfile to define model-service URL and service ports via environment variables, with app defaulting to 8080 and model-service to 8081.

#### Nicolas: https://github.com/doda25-team5/model-service/pull/4
Implemented Feature 9 by adding a Github Actions worklfow that automates model training and creates a Github release containing the generated model artifacts (the model, preprocessed_data and preprocessor joblib files).

#### Maja: https://github.com/doda25-team5/lib-version/actions/runs/19409393408, https://github.com/doda25-team5/lib-version/commit/70f6f248336be689bc5efeb0991d5b3e69b91447, https://github.com/doda25-team5/app/commit/96c0e769c29d73f96fb52ca15435d7ce793c9080
Implemented Feature 1 and 2. Due to the fact that those functionalities were the first ones, after I created the organization, I was committing to the main branch. On the next assignments I will be merging my features through PRs. For F1 I created a version-aware Maven library, made app depend on the library and created VersionUntil. Then I created a workflow for automatic packages and version lib-version to release it to Github package registry and added a version controller function in app. 

#### Jayran https://github.com/doda25-team5/app/pull/5, https://github.com/doda25-team5/model-service/pull/6, https://github.com/doda25-team5/lib-version/pull/2
Implemented F8 for both the app and model-service repositories, adding automated container image build-and-release workflows.
I also implemented F11 in the lib-version repository, adding automated stable releases, pre-releases, and version bumping.

#### Priyansh https://github.com/doda25-team5/operation/pull/1 https://github.com/doda25-team5/model-service/pull/5
Worked on Features 7 and 10. Set up the operation repo, cleaned up the Docker Compose setup, added .env support, linked the frontend and model-service images properly, and updated the configuration so everything runs smoothly together with the right environment variables.

