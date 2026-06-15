pipelineJob('test-pipeline') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/GrigoriPetrenko/local-proxmox-project.git')
                    }
                    branch('main')
                }
            }
            scriptPath('Jenkinsfile')
        }
    }
}