pipeline {
  agent { label 'docker-kubectl-node' }
  options { timestamps(); disableConcurrentBuilds(); timeout(time: 20, unit: 'MINUTES') }
  parameters {
    string(name: 'IMAGE_REPOSITORY', defaultValue: 'ghcr.io/your-org/blue-green-deployment-platform/demo-app', description: 'Set a writable registry repository before running.')
    string(name: 'KUBE_CONTEXT', defaultValue: 'kind-project6', description: 'Local Kind context configured on this agent.')
  }
  environment { REGISTRY = 'ghcr.io'; REGISTRY_CREDENTIALS = 'container-registry' }
  stages {
    stage('Test') { steps { checkout scm; sh 'node --test' } }
    stage('Build and publish') {
      steps {
        script { env.RELEASE_IMAGE = "${params.IMAGE_REPOSITORY}:${env.BUILD_NUMBER}" }
        withCredentials([usernamePassword(credentialsId: env.REGISTRY_CREDENTIALS, usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_TOKEN')]) {
          sh '''
            set +x
            printf '%s' "$REGISTRY_TOKEN" | docker login "$REGISTRY" --username "$REGISTRY_USER" --password-stdin
            docker build --pull -t "$RELEASE_IMAGE" .
            docker push "$RELEASE_IMAGE"
            docker logout "$REGISTRY"
          '''
        }
      }
    }
    stage('Promote') { steps { sh 'IMAGE="$RELEASE_IMAGE" VERSION="$BUILD_NUMBER" KUBE_CONTEXT="$KUBE_CONTEXT" ./scripts/promote.sh' } }
  }
  post { always { sh 'docker logout ghcr.io >/dev/null 2>&1 || true' } }
}
