import json
import logging
import yandexcloud
from yandex.cloud.compute.v1.instance_service_pb2 import GetInstanceRequest, StopInstanceRequest
from yandex.cloud.compute.v1.instance_service_pb2_grpc import InstanceServiceStub

# 1. Настройка профессионального логирования
logging.basicConfig(
    level=logging.INFO, # Выводить всё, начиная с уровня INFO
    format='%(asctime)s | %(levelname)-8s | %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

# ID сервера, который мы будем выключать (твой тестовый сервер)
INSTANCE_ID = 'serverID'

def main():
    logging.info("Инициализация скрипта автоматизации...")
    
    # Подгружаем ключи
    with open('authorized_key.json') as infile:
        auth_config = json.load(infile)

    # Подключаемся к SDK
    sdk = yandexcloud.SDK(service_account_key=auth_config)
    instance_service = sdk.client(InstanceServiceStub)

    logging.info(f"Проверка текущего статуса сервера {INSTANCE_ID}...")
    
    try:
        # Получаем информацию о конкретном сервере
        instance = instance_service.Get(GetInstanceRequest(instance_id=INSTANCE_ID))
        
        if instance.status == 2: # В API Яндекса 2 означает RUNNING
            logging.info(f"Сервер '{instance.name}' работает. Отправка команды Stop...")
            
            # Отправляем команду на выключение
            operation = instance_service.Stop(StopInstanceRequest(instance_id=INSTANCE_ID))
            
            logging.info(f"Команда успешно отправлена! ID операции: {operation.id}")
            logging.info("Сервер переходит в состояние остановки.")
        else:
            logging.warning(f"Сервер '{instance.name}' сейчас не запущен. Выключение отменено.")
            
    except Exception as e:
        # Если Яндекс вернет ошибку (например, нет прав), мы запишем это как ERROR
        logging.error(f"Произошла ошибка при обращении к API Яндекса: {e}")

if __name__ == '__main__':
    main()
