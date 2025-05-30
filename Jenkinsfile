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
          # Ensure the unpacked bundle can find libpython
          export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH

          # Bundle the *versioned* .so into the root of the exe as the *un*versioned filename
          pyinstaller --onefile \
            --add-binary "/usr/lib/aarch64-linux-gnu/libpython3.11.so.1.0:./libpython3.11.so" \
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