pipeline {
  agent { label 'docker-compose-node' }
  options { timestamps(); disableConcurrentBuilds(); timeout(time: 25, unit: 'MINUTES') }
  parameters { string(name: 'REGISTRY_REPOSITORY', defaultValue: 'ghcr.io/your-org/blue-green-deployment-platform', description: 'Set a writable registry namespace before running.') }
  environment { REGISTRY_HOST = 'ghcr.io'; REGISTRY_CREDENTIALS = 'container-registry' }
  stages {
    stage('Checkout and test') { steps { checkout scm; sh 'node --test' } }
    stage('Build and publish') {
      steps {
        script { env.FRONTEND_IMAGE = "${params.REGISTRY_REPOSITORY}/frontend:${env.BUILD_NUMBER}"; env.BACKEND_IMAGE = "${params.REGISTRY_REPOSITORY}/backend:${env.BUILD_NUMBER}" }
        withCredentials([usernamePassword(credentialsId: env.REGISTRY_CREDENTIALS, usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_TOKEN')]) {
          sh '''
            set +x
            printf '%s' "$REGISTRY_TOKEN" | docker login "$REGISTRY_HOST" --username "$REGISTRY_USER" --password-stdin
            docker build -f frontend/Dockerfile -t "$FRONTEND_IMAGE" .
            docker build -f backend/Dockerfile -t "$BACKEND_IMAGE" .
            docker push "$FRONTEND_IMAGE"
            docker push "$BACKEND_IMAGE"
            docker logout "$REGISTRY_HOST"
          '''
        }
      }
    }
    stage('Deploy inactive and promote') {
      steps { sh 'VERSION="$BUILD_NUMBER" FRONTEND_IMAGE="$FRONTEND_IMAGE" BACKEND_IMAGE="$BACKEND_IMAGE" PULL_IMAGES=true ./scripts/deploy-inactive.sh' }
    }
  }
  post { always { sh 'docker logout ghcr.io >/dev/null 2>&1 || true' } }
}
