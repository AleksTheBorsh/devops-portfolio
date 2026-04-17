import boto3
import os
import logging
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO, format='%(asctime)s | %(levelname)s | %(message)s')

ACCESS_KEY = 'ТВОЙ_КЛЮЧ'
SECRET_KEY = 'ТВОЙ_СЕКРЕТ'
BUCKET_NAME = 'имя-твоего-бакета'
FOLDER_PATH = './my_configs'  # Путь к папке, которую хочешь загрузить

def upload_folder():
    session = boto3.session.Session()
    s3 = session.client(
        service_name='s3',
        endpoint_url='https://storage.yandexcloud.net',
        aws_access_key_id=ACCESS_KEY,
        aws_secret_access_key=SECRET_KEY,
        region_name='ru-central1'
    )

    # Проходим циклом по всем файлам в папке
    for root, dirs, files in os.walk(FOLDER_PATH):
        for file in files:
            local_path = os.path.join(root, file)
            # Формируем имя файла в бакете (относительный путь)
            s3_path = os.path.relpath(local_path, FOLDER_PATH)

            # --- ПРОВЕРКА НА ПОВТОРЫ ---
            try:
                # Метод head_object просто запрашивает метаданные файла
                s3.head_object(Bucket=BUCKET_NAME, Key=s3_path)
                logging.info(f"⏩ Файл {s3_path} уже есть в бакете, пропускаю...")
            except ClientError as e:
                # Если файл не найден (ошибка 404), значит его нужно загрузить
                if e.response['Error']['Code'] == "404":
                    try:
                        s3.upload_file(local_path, BUCKET_NAME, s3_path)
                        logging.info(f"✅ Загружен: {s3_path}")
                    except Exception as upload_err:
                        logging.error(f"❌ Ошибка загрузки {s3_path}: {upload_err}")
                else:
                    logging.error(f"❌ Ошибка проверки файла: {e}")

if __name__ == "__main__":
    upload_folder()