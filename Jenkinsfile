pipeline {
    agent any

    environment {
        FLUTTER_HOME = '/usr/local/flutter'
        ANDROID_HOME = '/usr/local/sdk'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${FLUTTER_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${JAVA_HOME}/bin:${env.PATH}"
    }

    parameters {
        // 在Jenkins构建时传递url和fbc的值
        string(name: 'URL', defaultValue: 'https://www.baidu.com', description: 'The URL to be used in the app')
        string(name: 'FBC', defaultValue: '123', description: 'The FBC value to be used in the app')
    }

    stages {
        stage('Checkout') {
            steps {
                // 从 Git 仓库拉取最新代码
                git branch: 'main', url: 'https://github.com/bigbangkobe/NaturichProst.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // 进入 flutter 项目的实际根目录
                dir('naturichprost') {
                    // 安装 Flutter 依赖
                    sh 'flutter pub get'
                }
            }
        }

        stage('Generate Config File') {
            steps {
                script {
                    // 动态生成 config.json 文件，将 URL 和 FBC 的值写入文件
                    writeFile file: 'naturichprost/assets/config/config.json', text: """
                    {
                        "url": "${params.URL}",
                        "fbc": "${params.FBC}"
                    }
                    """
                }
            }
        }

        stage('Build APK') {
            steps {
                // 进入 flutter 项目的实际根目录并构建 APK
                dir('naturichprost') {
                    // 构建 Release APK
                    sh 'flutter build apk --release --build-name=1.0.0 --build-number=1'
                }
            }
        }

        stage('Archive APK') {
            steps {
                // 存档构建的 APK 文件
                archiveArtifacts artifacts: 'naturichprost/build/app/outputs/flutter-apk/*.apk', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            // 在每次构建后清理工作区
            cleanWs()
        }
    }
}
