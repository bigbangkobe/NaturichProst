pipeline {
    agent any

    environment {
        FLUTTER_HOME = '/usr/local/flutter'
        ANDROID_HOME = '/usr/local/sdk'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${FLUTTER_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${JAVA_HOME}/bin:${env.PATH}"
        FTP_SERVER = 'ftp://0'
        FTP_USERNAME = 'your-ftp-username'
        FTP_PASSWORD = 'your-ftp-password'
        FTP_UPLOAD_PATH = '/path/to/upload/directory'
    }

    parameters {
        // 在Jenkins构建时传递url和fbc的值
        string(name: 'URL', defaultValue: 'https://www.baidu.com', description: 'The URL to be used in the app')
        string(name: 'FBC', defaultValue: '123', description: 'The FBC value to be used in the app')
        string(name: 'NAME', defaultValue: 'APP', description: 'App Name')
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
                        "fbc": "${params.FBC}",
                        "name": "${params.NAME}"
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
        
        stage('Rename APK') {
            steps {
                script {
                    // 获取当前时间戳
                    def timestamp = sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
                    def appName = 'naturichprost'  // 替换为你的应用名称（或动态获取）
                    def url = params.URL.replaceAll('https?://', '').replaceAll('/', '_')  // 将URL中的特殊字符转换为下划线
                    def fbc = params.FBC

                    // 设置新的 APK 文件名
                    def newApkName = "${appName}_${url}_${fbc}_${timestamp}.apk"

                    // 定义 APK 文件路径
                    def apkPath = 'naturichprost/build/app/outputs/flutter-apk/app-release.apk'

                    // 重命名 APK 文件
                    sh "mv ${apkPath} naturichprost/build/app/outputs/flutter-apk/${newApkName}"

                    echo "Renamed APK to ${newApkName}"
                }
            }
        }

        stage('Upload to FTP') {
            steps {
                script {
                    // 使用 curl 命令将文件上传到 FTP 服务器
                    def newApkPath = "naturichprost/build/app/outputs/flutter-apk/${newApkName}"
                    def ftpUrl = "ftp://${FTP_USERNAME}:${FTP_PASSWORD}@${FTP_SERVER}${FTP_UPLOAD_PATH}/${newApkName}"

                    // 上传 APK 文件到 FTP
                    sh """
                        curl -T ${newApkPath} ${ftpUrl}
                    """
                    echo "APK uploaded to FTP server."
                }
            }
        }

        stage('Generate Download URL') {
            steps {
                script {
                    // 生成下载链接
                    def downloadUrl = "http://${FTP_SERVER}${FTP_UPLOAD_PATH}/${newApkName}"
                    echo "Download URL: ${downloadUrl}"
                    
                    // 将下载链接输出到 Jenkins 控制台
                    currentBuild.description = "APK is ready for download: ${downloadUrl}"
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
            echo 'Build completed without workspace cleanup.'
        }
    }
}
