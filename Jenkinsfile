node {

    def scmVars

    stage('scm-clone') {
        scmVars = checkout([$class: 'GitSCM', branches: [[name: '*/tags/*']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[refspec: '+refs/tags/*:refs/remotes/origin/tags/*', url: 'https://github.com/mikebrady/shairport-sync.git']]])
        echo 'yay'
        echo scmVars.GIT_BRANCH
    }

    stage('dockerfile-clone') {
        dir('docker') {
            git "https://github.com/orbsmiv/docker-shairport-sync-rpi.git"
        }
    }

    stage('build-docker-image') {
        echo pwd()
        echo "Building image"
        // def newImage = docker.build("my-image:${something}", "./docker")
        // newImage.push()

    }


}
