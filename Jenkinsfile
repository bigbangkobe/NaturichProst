pipeline {
    agent any

    environment {
        FLUTTER_HOME = '/usr/local/flutter'
        ANDROID_HOME = '/usr/local/sdk'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${FLUTTER_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${JAVA_HOME}/bin:${env.PATH}"
        FTP_SERVER = 'naturich.top'
        FTP_USERNAME = 'ftpuser'
        FTP_PASSWORD = 'Aa910625963'
        FTP_UPLOAD_PATH = '/home/ftpuser'
        NEW_APK_NAME = 'apk'
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
                    def appName = params.NAME  // 替换为你的应用名称（或动态获取）
                    def url = params.URL.replaceAll('https?://', '').replaceAll('/', '_')  // 将URL中的特殊字符转换为下划线
                    def fbc = params.FBC

                    // 设置新的 APK 文件名
                    def newApkName = "${appName}_${url}_${fbc}_${timestamp}.apk"
                    // 将新的 APK 名称保存为环境变量，以便在后续步骤中使用
                    env.NEW_APK_NAME = newApkName
                    // 定义 APK 文件路径
                    def apkPath = 'naturichprost/build/app/outputs/flutter-apk/app-release.apk'

                    // 重命名 APK 文件
                    sh "mv ${apkPath} naturichprost/build/app/outputs/flutter-apk/${newApkName}"

                    echo "Renamed APK to ${newApkName}"
                }
            }
        }

        stage('Upload to SFTP') {
            steps {
                script {
                    try {
                        // 设置上传路径
                        def newApkPath = "naturichprost/build/app/outputs/flutter-apk/${env.NEW_APK_NAME}"
                        def sftpUrl = "${FTP_USERNAME}@${FTP_SERVER}:${FTP_UPLOAD_PATH}"

                        // 使用 sshpass 工具传递密码并上传 APK 文件
                        sh """
                            # 使用 sshpass 自动输入密码并上传文件
                            sshpass -p '${FTP_PASSWORD}' sftp -oBatchMode=no -oStrictHostKeyChecking=no ${sftpUrl} <<< "put ${newApkPath}"
                        """
                        echo "APK uploaded to SFTP server."
                    } catch (Exception e) {
                        // 输出错误信息
                        echo "SFTP upload failed with error: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE'  // 设置构建状态为失败
                        throw e  // 抛出异常，终止后续步骤
                    }
                }
            }
        }


        stage('Generate Download URL') {
            steps {
                script {
                    // 生成下载链接
                    def downloadUrl = "http://${FTP_SERVER}${FTP_UPLOAD_PATH}/${env.NEW_APK_NAME}"
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
