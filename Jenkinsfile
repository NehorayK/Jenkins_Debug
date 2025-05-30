pipeline {
  // ---- use your SSH‐based agent ----
  agent { label 'docker-ssh' }

  stages {
    stage('Setup') {
      steps {
        echo 'Installing dependencies…'
        sh '''
          set -e
          # if your container user has sudo, you can prefix sudo here:
          # sudo apt-get update
          apt-get update
          apt-get install -y python3 python3-pip wget curl
          pip3 install --upgrade pip
          pip3 install pylint pyinstaller flask pipenv
        '''
      }
    }

    stage('Lint') {
      steps {
        echo 'Static code analysis…'
        sh 'pylint --disable=missing-docstring,invalid-name app.py || true'
      }
    }

    stage('Build') {
      steps {
        echo 'Building with PyInstaller…'
        sh '''
          set -e
          pyinstaller --onefile app.py
        '''
      }
    }

    stage('Test') {
      steps {
        echo 'Starting app & hitting endpoints…'
        sh '''
          set -e
          nohup ./dist/app & sleep 5
          curl -f http://localhost:8080
          curl -f http://localhost:8080/jenkins
        '''
      }
    }

    stage('Archive') {
      steps {
        echo 'Archiving artifacts…'
        archiveArtifacts artifacts: 'dist/**', fingerprint: true
      }
    }
  }
}