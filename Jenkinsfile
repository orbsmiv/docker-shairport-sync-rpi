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
        def tagName = tagFinder(scmVars.GIT_BRANCH)
        echo tagName

        def metaTag

        // Check if the tag is a release or dev/RC etc. build
        if (releaseChecker(tagName))
            metaTag = "latest"
        else
            metaTag = "development"

        echo metaTag
        // def something = 'develop'
        // echo pwd()
        echo "Building image"
        def newImage = docker.build("orbsmiv/shairport-sync-rpi:${tagName}", "--pull --build-arg SHAIRPORT_VER=\"${tagName}\" ./docker")
        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
            newImage.push()
            newImage.push(metaTag)
        }
    }

}

@NonCPS
def tagFinder(text) {
    def matcher = text =~ ".*/(.*)"
    matcher ? matcher[0][1] : null
}

@NonCPS
def releaseChecker(text) {
    // returns true if matches regex
    matcher = text ==~ "^\\d+\\.\\d+\\.*\\d*\$"
}
