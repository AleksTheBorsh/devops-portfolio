from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "🚀 Ура! Наш Full-Cycle CI/CD работает. Версия 1.0!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
