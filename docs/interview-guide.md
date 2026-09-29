# Interview guide

Jenkins checks out code, tests it, builds and publishes an immutable image with credentials stored in Jenkins. The promotion script finds the inactive color, updates it, waits for readiness, and checks health and release identity before switching the Service. It probes through the stable Service after switching and restores the old selector if that check fails.

Two Deployments leave the previous release available, but require spare capacity. Selector switching is not gradual canary traffic; long-lived connections drain over time. Rollback restores routing and does not reverse schema or queue changes. The stateless demo and Kind cluster do not prove zero failed requests in all production conditions. Scope Jenkins credentials and Kubernetes permissions narrowly.
