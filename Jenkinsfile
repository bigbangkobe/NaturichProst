pipeline {
    agent any

    environment {
        FLUTTER_HOME = '/usr/local/flutter'
        ANDROID_HOME = '/usr/local/sdk'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${FLUTTER_HOME}/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${JAVA_HOME}/bin:${env.PATH}"
    }

    parameters {
        string(name: 'NAME', defaultValue: 'Naturich', description: 'Application name to select icon and package (e.g., naturich, other).')
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
                    // 安装 Flutter 依赖
                    sh 'flutter pub get'
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
                script {
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
                    // 构建 APK
                    sh 'flutter build apk --release --build-name=1.0.0 --build-number=1 --no-tree-shake-icons'
                }
            }
        }

        stage('Rename APK') {
            steps {
                script {
                    def timestamp = sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim()
                    def appName = params.NAME.toLowerCase()  // 确保使用小写
                    def newApkName = "${appName}_${timestamp}.apk"
                    currentBuild.description = newApkName
                    
                    def apkPath = 'naturichprost/build/app/outputs/flutter-apk/app-release.apk'
                    sh "mv ${apkPath} naturichprost/build/app/outputs/flutter-apk/${currentBuild.description}"

                    echo "Renamed APK to ${currentBuild.description}"
                }
            }
        }

        stage('Upload to SFTP') {
            steps {
                script {
                    // 上传到 FTP 服务器
                    def sftpUrl = "${FTP_USERNAME}@${FTP_SERVER}:${FTP_UPLOAD_PATH}"
                    def newApkPath = "naturichprost/build/app/outputs/flutter-apk/${currentBuild.description}"

                    writeFile(file: 'sftp_commands.txt', text: "put ${newApkPath}")

                    sh """
                        sshpass -p '${FTP_PASSWORD}' sftp -oBatchMode=no -oStrictHostKeyChecking=no -b sftp_commands.txt ${sftpUrl}
                    """
                }
            }
        }

        stage('Generate Download URL') {
            steps {
                script {
                    def downloadUrl = "https://${FTP_SERVER}${FTP_UPLOAD_PATH}/${currentBuild.description}"
                    echo "Download URL: ${downloadUrl}"
                    currentBuild.description = downloadUrl
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace...'
        }
    }
}
