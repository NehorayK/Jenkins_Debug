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
          # ensure that the extracted directory can resolve shared libs
          export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH

          # create a one-dir bundle so the .so lives alongside the exe
          pyinstaller --clean --log-level=INFO --onedir \
            --add-binary "/usr/lib/aarch64-linux-gnu/libpython3.11.so.1.0:." \
            app.py
        '''
      }
    }

    stage('Test') {
      steps {
        echo 'Starting app & testing endpoints…'
        sh '''
          set -e
          # run the actual binary from the onedir layout
          nohup ./dist/app/app & sleep 5
          curl -f http://127.0.0.1:8000
          curl -f http://127.0.0.1:8000/jenkins
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