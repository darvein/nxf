# Bash sample Jenkinsfile
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: shell
    image: alpine:latest
    command:
    - sleep
    args:
    - infinity
'''
            defaultContainer 'shell'
        }
    }

    triggers {
        cron('0 2 * * *')
    }

    parameters {
      choice(
          name: 'ES_ENVIRONMENT',
          choices: ["app", "staging", "devtest", "devbox"],
          description: 'Select the Target ElasticSearch environment' )
    }

    stages {
        stage('Main') {
            steps {
              sh "apk update && apk add --no-cache curl  bash jq"
              sh "cd jenkins/elasticsearch-snapshots; ES_ENVIRONMENT=${params.ES_ENVIRONMENT} /bin/bash generate-snapshot.sh"
            }
        }
    }
}
