pipeline {
    // Выполнять на любом доступном агенте (в нашем случае - прямо внутри контейнера Jenkins)
    agent any

    // Этапы нашего конвейера
    stages {
        stage('Проверка связи') {
            steps {
                echo '🎉 Ура! Jenkins успешно прочитал мой Jenkinsfile!'
            }
        }
        stage('Системная информация') {
            steps {
                // Команда 'sh' выполняет обычные bash-команды Linux
                sh 'echo "Я работаю внутри контейнера:"'
                sh 'hostname'
                sh 'uptime'
            }
        }
    }
}
