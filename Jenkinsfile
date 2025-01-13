pipeline {
    agent any

    environment {
        FLUTTER_HOME = '/usr/local/flutter'
        ANDROID_HOME = '/usr/local/sdk'
        PATH = "${FLUTTER_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${env.PATH}"
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

        stage('Deploy') {
            steps {
                // 例如将 APK 上传到远程服务器（可选）
                sh 'scp naturichprost/build/app/outputs/flutter-apk/app-release.apk user@yourserver:/path/to/destination/'
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
