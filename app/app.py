import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# DevOps-магия: берем адрес БД из настроек сервера. 
# Если переменной нет (мы еще не подключили Постгрес), используем локальный файлик sqlite
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///local_test.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Описываем таблицу в базе данных
class Visit(db.Model):
    id = db.Column(db.Integer, primary_key=True)

# Автоматически создаем таблицу при старте, если её еще нет
with app.app_context():
    db.create_all()

@app.route('/')
def hello_world():
    # Записываем новое посещение в БД
    new_visit = Visit()
    db.session.add(new_visit)
    db.session.commit()
    
    # Считаем, сколько всего записей в таблице
    visits_count = Visit.query.count()

    return f'''
    <h1>Привет, Мир! 🌍</h1>
    <h2>Это DevOps-портфолио AleksTheBorsh</h2>
    <p>Инфраструктура: Yandex Cloud + Docker + Ansible</p>
    <hr>
    <p><b>Вы посетитель №: {visits_count}</b></p>
    <p><small>База данных работает и сохраняет информацию!</small></p>
    '''

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
