pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node18'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('Checkout from Git') {
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            url: 'https://github.com/mehmetsungur/UptimeKuma.git',
                            credentialsId: 'github-token'
                        ]]
                    ])
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install --unsafe-perm=true --allow-root"
            }
        }
        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectName=uptime -Dsonar.projectKey=uptime'
                }
            }
        }
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.json"
            }
        }
        stage("Docker Build & Push") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t uptime ."
                        sh "docker tag uptime mehmetsungur/uptime:latest"
                        sh "docker push mehmetsungur/uptime:latest"
                    }
                }
            }
        }
        stage("TRIVY Image Scan") {
            steps {
                sh "trivy image mehmetsungur/uptime:latest > trivy.json"
            }
        }
        stage("Remove Previous Container") {
            steps {
                sh "docker stop uptime || true"
                sh "docker rm uptime || true"
            }
        }
        stage('Deploy to Container') {
            steps {
                sh 'docker run -d --name falcon -v /var/run/docker.sock:/var/run/docker.sock -p 3001:3001 mehmetsungur/uptime:latest'
            }
        }
    }
}
