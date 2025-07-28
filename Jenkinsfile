pipeline {
    agent any

    environment {
        FLUTTER_HOME = '/usr/local/flutter'
        ANDROID_HOME = '/usr/local/sdk'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${FLUTTER_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${JAVA_HOME}/bin:${env.PATH}"
        FTP_SERVER = 'naturich.xin'
        FTP_USERNAME = 'ftpuser'
        FTP_PASSWORD = 'Aa910625963'
        FTP_UPLOAD_PATH = '/home/ftpuser'
    }

    parameters {
        string(name: 'URL', defaultValue: 'https://www.baidu.com', description: 'The URL to be used in the app')
        string(name: 'FBC', defaultValue: '123', description: 'The FBC value to be used in the app')
        string(name: 'NAME', defaultValue: 'APP', description: 'TR8BET')
    }

    stages {
        stage('Checkout') {
            steps {
                // 拉取最新代码
                git branch: 'main', url: 'https://github.com/bigbangkobe/NaturichProst.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('naturichprost') {
                    // 使用缓存 Flutter 依赖，避免每次都重新下载
                    sh '''
                        if [ ! -d "$WORKSPACE/.pub-cache" ]; then
                            flutter pub get
                        else
                            echo "Using cached Flutter dependencies"
                        fi
                    '''
                }
            }
        }

        stage('Set App Name and Icon') {
            steps {
                script {
                    // 获取传入的 NAME 参数
                    def appName = params.NAME
                    //def packageName = "com.naturichprost.${appName.toLowerCase()}"  // 只将 appName 转为小写

                    // 修改 pubspec.yaml 中的应用名称
                    writeFile file: 'naturichprost/pubspec.yaml', text: readFile('naturichprost/pubspec.yaml').replaceAll(/name: .*/, "name: ${appName}")

                    // 修改 AndroidManifest.xml 中的应用名称
                    sh """
                        sed -i 's/android:label=".*"/android:label="${appName}"/' naturichprost/android/app/src/main/AndroidManifest.xml
                    """

                    // // 修改 build.gradle 中的包名
                    // sh """
                    //     sed -i 's/applicationId "com.naturichprost"/applicationId "${packageName}"/' naturichprost/android/app/build.gradle
                    // """

                    // 更新图标路径
                    def iconPath = "assets/${appName}.jpg"
                    writeFile file: 'naturichprost/pubspec.yaml', text: readFile('naturichprost/pubspec.yaml').replaceAll(/image_path: "assets\/.*\.jpg"/, "image_path: \"${iconPath}\"")
                }
            }
        }

        stage('Generate Launcher Icons') {
            steps {
               // 确保工作目录为 Flutter 项目的根目录
                dir('naturichprost') {
                    // 运行 flutter_launcher_icons 来生成图标
                    sh 'flutter pub run flutter_launcher_icons:main'
                }
            }
        }

        stage('Generate Config File') {
            steps {
                script {
                    // 生成 config.json 文件
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
                dir('naturichprost') {
                    // 增量构建：避免完全重建所有部分，特别是图标等
                    sh '''
                        flutter build apk --release --build-name=1.0.0 --build-number=1 --no-tree-shake-icons
                        echo "APK built at: ${PWD}/build/app/outputs/flutter-apk/"
                    '''
                }
            }
        }

         stage('Rename APK') {
            steps {
                script {
                    // 获取当前时间戳
                    def timestamp = sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
                    def appName = params.NAME  // 应用名称（动态获取）
                    def url = params.URL.replaceAll('https?://', '').replaceAll('/', '_')  // URL 转换为有效文件名
                    def fbc = params.FBC

                    // 设置新的 APK 文件名
                    def newApkName = "${appName}_${fbc}_${timestamp}.apk"
                    currentBuild.description = newApkName
                    
                    // 使用环境变量命名 APK
                    def apkPath = 'naturichprost/build/app/outputs/flutter-apk/app-release.apk'
                    sh "mv ${apkPath} naturichprost/build/app/outputs/flutter-apk/${currentBuild.description}"

                    echo "Renamed APK to ${currentBuild.description}"
                }
            }
        }

        stage('Upload to SFTP') {
            steps {
                script {
                    try {
                        // 设置上传路径
                        def newApkPath = "naturichprost/build/app/outputs/flutter-apk/${currentBuild.description}"
                        def sftpUrl = "${FTP_USERNAME}@${FTP_SERVER}:${FTP_UPLOAD_PATH}"

                        // 创建一个临时文件并写入 put 命令
                        writeFile(file: 'sftp_commands.txt', text: "put ${newApkPath}")

                        // 使用 sshpass 和 sftp 上传文件
                        sh """
                            #!/bin/bash
                            sshpass -p '${FTP_PASSWORD}' sftp -oBatchMode=no -oStrictHostKeyChecking=no -b sftp_commands.txt ${sftpUrl}
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
                    def downloadUrl = "https://${FTP_SERVER}${FTP_UPLOAD_PATH}/${currentBuild.description}"
                    echo "Download URL: ${downloadUrl}"
                    
                    // 将下载链接输出到 Jenkins 控制台
                    currentBuild.description = downloadUrl
                }
            }
        }
    }

    post {
        always {
            // 清理工作区
            echo 'Cleaning workspace...'
            //deleteDir()  // 删除工作区中的所有文件和目录
        }
    }
}
