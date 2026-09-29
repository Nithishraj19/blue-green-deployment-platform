# Docker blue-green architecture

GitHub starts a Jenkins pipeline that tests the Node.js application, builds separate frontend and backend images, and pushes immutable tags to the configured OCI registry. Jenkins deploys the inactive Compose color while the current color continues serving requests. Each color has its own frontend, API, catalog and billing containers.

The frontend calls its same-color API, which checks both same-color services. The promotion script validates health and release identity from inside the candidate stack. Nginx then loads the candidate upstream and reloads gracefully. A post-switch check through the public proxy confirms the expected version; if it fails, the script restores the previous upstream and reloads Nginx.

Only Nginx publishes a host port. The blue/green application services stay on a private Compose network. The Docker API is an application API; this project does not mount the Docker socket. It is a local-first Docker demonstration and does not provision AWS or Kubernetes resources.
