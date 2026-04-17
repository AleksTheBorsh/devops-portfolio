import json
import logging
import yandexcloud
from yandex.cloud.mdb.postgresql.v1.cluster_service_pb2 import ListClustersRequest
from yandex.cloud.mdb.postgresql.v1.cluster_service_pb2_grpc import ClusterServiceStub

logging.basicConfig(level=logging.INFO, format='%(asctime)s | %(levelname)-8s | %(message)s', datefmt='%H:%M:%S')
FOLDER_ID = 'b1gi80mvh2p8j0611ckc' # Вставь свой ID каталога

def main():
    logging.info("Авторизация робота для работы с Базами Данных (PostgreSQL)...")
    with open('authorized_key.json') as infile:
        sdk = yandexcloud.SDK(service_account_key=json.load(infile))

    db_service = sdk.client(ClusterServiceStub)
    
    logging.info("Поиск кластеров PostgreSQL...")
    try:
        clusters = db_service.List(ListClustersRequest(folder_id=FOLDER_ID)).clusters
        
        if not clusters:
            logging.info("Управляемые базы данных не найдены.")
        else:
            print("\n--- Базы данных (PostgreSQL) ---")
            for db in clusters:
                # В Яндексе status 2 - это RUNNING
                status = "🟢 Онлайн" if db.status == 2 else f"🟡 Статус: {db.status}"
                print(f"[{status}] Имя: {db.name} | Окружение: {db.environment} | ID: {db.id}")
            print("--------------------------------\n")
    except Exception as e:
        logging.error(f"Ошибка доступа (проверь, есть ли у робота роль mdb.viewer или mdb.editor): {e}")

if __name__ == '__main__':
    main()