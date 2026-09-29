# Architecture

GitHub triggers Jenkins to test the app, build an immutable image and publish it to an OCI registry. Jenkins updates the inactive Kubernetes Deployment, waits for rollout readiness and probes `/health` and `/version`. Once the candidate passes, it patches the stable ClusterIP Service selector to send traffic to that color. A failed post-switch check restores the previous selector.

Two Deployments retain the previous release for quick traffic rollback. Each has two replicas and startup, readiness and liveness probes. This local demo uses a Service selector rather than an Ingress controller or cloud load balancer. The promotion script accepts only `kind-` contexts.
