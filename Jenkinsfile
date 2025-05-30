pipeline {
  agent { label 'docker-ssh' }

  stages {
    stage('Verify Environment') {
      steps {
        echo 'Checking that all tools are available…'
        sh '''
          set -e
          python3 --version
          pip --version
          pyinstaller --version
          pylint --version
          flask --version
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
        export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu
        pyinstaller --onefile app.py
        '''
      }
    }

    stage('Test') {
      steps {
        echo 'Starting app & testing endpoints…'
        sh '''
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