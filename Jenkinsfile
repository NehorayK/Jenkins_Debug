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
          set -e
          # make sure the unpacked binary can load the system’s libpython
          export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu

          # bundle the shared library into the exe under the expected name
          pyinstaller --onefile \
            --add-binary "/usr/lib/aarch64-linux-gnu/libpython3.11.so.1.0:libpython3.11.so" \
            app.py
        '''
      }
    }

    stage('Test') {
      steps {
        echo 'Starting app & testing endpoints…'
        sh '''
          set -e
          nohup ./dist/app & sleep 5
          curl -f http://localhost:8000
          curl -f http://localhost:8000/jenkins
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