# Interview guide

## Describe the release

Jenkins runs the Node.js tests, builds frontend and backend images, tags them with the build number and pushes them to a configured registry using a Jenkins-managed credential. It finds the inactive color from Nginx's current upstream, pulls and starts that color's frontend, API, catalog and billing containers, then checks container health plus `/health` and `/version` across the complete stack. Only after those checks pass does Nginx reload with the new upstream. The script verifies the public route and automatically switches back if that check fails.

## Why Compose and Nginx?

This project models selected workloads on Docker hosts where a full Kubernetes control plane is not part of the deployment requirement. Compose describes the two isolated application colors; Nginx is the stable client entry point and makes traffic selection explicit. The mechanism can run locally without an always-on cloud environment.

## Safety and trade-offs

- Both colors consume resources during a release; capacity must cover the overlap.
- The active upstream file is changed atomically and Nginx is tested before reload.
- Candidate checks do not alter live routing. The public path is checked again after switching, with automatic rollback on failure.
- Keep the previous color and image until the new release is accepted. Rollback restores traffic; it does not reverse database changes.
- The demonstration uses stateless services. Real services need backward-compatible API and data migrations, draining behavior, and persistent state outside container filesystems.
- Jenkins needs access to the Docker host and Compose project directory; registry credentials stay in Jenkins. The containers do not receive Docker socket access.
- This is a portfolio/local implementation, not a claim of deployment to AWS or production.
