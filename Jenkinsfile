pipeline {
    agent any

    triggers {
        githubPush()
    }

    options {
        disableConcurrentBuilds()
        timeout(time: 45, unit: 'MINUTES')
        timestamps()
    }

    environment {
        APP_NAME = 'BatchIt'
        DEPLOY_DIR = '/var/www/batchit'
        WEBSITE_SRC = 'website'
        FLUTTER_HOME = '/opt/flutter'
        ANDROID_HOME = '/usr/lib/android-sdk'
        ANDROID_SDK_ROOT = '/usr/lib/android-sdk'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        MIN_COVERAGE = '70'
        PATH = "${FLUTTER_HOME}/bin:${JAVA_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Toolchain') {
            steps {
                sh '''#!/bin/bash
                    set -e
                    flutter --version
                    java -version
                    which sdkmanager || true
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''#!/bin/bash
                    set -e
                    flutter pub get
                '''
            }
        }

        stage('Analyze') {
            steps {
                sh '''#!/bin/bash
                    set -e
                    flutter analyze --no-pub
                '''
            }
        }

        stage('Run Tests and Coverage') {
            when {
                expression { fileExists('test') }
            }
            steps {
                sh '''#!/bin/bash
                    set -e

                    flutter test --coverage

                    if [ ! -f coverage/lcov.info ]; then
                        echo "No lcov report generated"
                        exit 1
                    fi

                    total_lines=$(grep -E "^LF:" coverage/lcov.info | awk -F: '{sum += $2} END {print sum + 0}')
                    covered_lines=$(grep -E "^LH:" coverage/lcov.info | awk -F: '{sum += $2} END {print sum + 0}')

                    mkdir -p coverage_reports

                    if [ "$total_lines" -eq 0 ]; then
                        echo "No measurable lines found in lcov report" > coverage_reports/coverage_summary.txt
                        exit 1
                    fi

                    coverage_pct=$((covered_lines * 100 / total_lines))

                    {
                        echo "Flutter Coverage Summary"
                        echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
                        echo "Total lines: $total_lines"
                        echo "Covered lines: $covered_lines"
                        echo "Coverage: ${coverage_pct}%"
                        echo "Required minimum: ${MIN_COVERAGE}%"
                    } > coverage_reports/coverage_summary.txt

                    echo "$coverage_pct" > coverage_reports/coverage_percentage.txt

                    if [ "$coverage_pct" -lt "$MIN_COVERAGE" ]; then
                        echo "Coverage gate failed: ${coverage_pct}% is below ${MIN_COVERAGE}%"
                        exit 1
                    fi
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'coverage_reports/**', fingerprint: false, allowEmptyArchive: true
                }
            }
        }

        stage('Build Android Artifacts') {
            steps {
                sh '''#!/bin/bash
                    set -e
                    flutter build apk --release
                    flutter build appbundle --release
                '''
            }
        }

        stage('Prepare Website Package') {
            steps {
                sh '''#!/bin/bash
                    set -e

                    DEPLOY_STAGING="deploy/site"
                    rm -rf deploy
                    mkdir -p "$DEPLOY_STAGING"
                    mkdir -p "$DEPLOY_STAGING/download"
                    mkdir -p "$DEPLOY_STAGING/js"

                    if [ -d "$WEBSITE_SRC" ]; then
                        cp -R "$WEBSITE_SRC"/. "$DEPLOY_STAGING"/
                    fi

                    if [ -f build/app/outputs/flutter-apk/app-release.apk ]; then
                        cp build/app/outputs/flutter-apk/app-release.apk "$DEPLOY_STAGING/download/BatchIt.apk"
                    else
                        echo "Missing APK output"
                        exit 1
                    fi

                    if [ -f build/app/outputs/bundle/release/app-release.aab ]; then
                        cp build/app/outputs/bundle/release/app-release.aab "$DEPLOY_STAGING/download/app-release.aab"
                    else
                        echo "Missing AAB output"
                        exit 1
                    fi

                    apk_sha256=$(sha256sum "$DEPLOY_STAGING/download/BatchIt.apk" | awk '{print $1}')
                    aab_sha256=$(sha256sum "$DEPLOY_STAGING/download/app-release.aab" | awk '{print $1}')
                    deployed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)

                    cat > "$DEPLOY_STAGING/js/deployment-info.json" <<EOF
{
  "app_name": "${APP_NAME}",
  "build_number": "${BUILD_NUMBER}",
  "job_name": "${JOB_NAME}",
  "build_url": "${BUILD_URL}",
  "deployed_at_utc": "${deployed_at}",
  "artifacts": {
    "apk": {
            "path": "download/BatchIt.apk",
      "sha256": "${apk_sha256}"
    },
    "aab": {
      "path": "download/app-release.aab",
      "sha256": "${aab_sha256}"
    }
  }
}
EOF
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'deploy/site/**', fingerprint: true, allowEmptyArchive: false
                }
            }
        }

        stage('Deploy Website to VPS') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                sh '''#!/bin/bash
                    set -e
                    mkdir -p "$DEPLOY_DIR"
                    rsync -a --delete deploy/site/ "$DEPLOY_DIR"/
                '''
            }
        }
    }

    post {
        success {
            echo 'Build, test, and deployment completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs for details.'
        }
        always {
            archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk', fingerprint: true, allowEmptyArchive: true
            archiveArtifacts artifacts: 'build/app/outputs/bundle/release/app-release.aab', fingerprint: true, allowEmptyArchive: true
        }
    }
}
