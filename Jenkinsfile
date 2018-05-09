// pipeline {
//     steps {
//         git url: 'https://github.com/orbsmiv/docker-shairport-sync-rpi.git'
//     }
// }


pipeline {

    agent any

    stages {
        stage('info') {
            steps {
                // checkout scm
                // echo 'Hello World'
                // echo env.WORKSPACE
                echo env.GIT_BRANCH
                sh('pwd')
                // git url: 'https://github.com/orbsmiv/docker-shairport-sync-rpi.git'
                sh('ls -la')
                // echo env.GIT_BRANCH
            }
        }
    }
}
