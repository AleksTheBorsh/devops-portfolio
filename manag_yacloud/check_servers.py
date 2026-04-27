import json
import yandexcloud
from yandex.cloud.compute.v1.instance_service_pb2 import ListInstancesRequest
from yandex.cloud.compute.v1.instance_service_pb2_grpc import InstanceServiceStub

# 1. Твой ID каталога в Яндекс Облаке (вставь свой)
FOLDER_ID = 'FOLDERID' 

# 2. Читаем "паспорт" робота из файла
with open('authorized_key.json') as infile:
    auth_config = json.load(infile)

# 3. Подключаемся к облаку от имени робота
sdk = yandexcloud.SDK(service_account_key=auth_config)

# 4. Обращаемся к сервису виртуальных машин (Compute)
instance_service = sdk.client(InstanceServiceStub)

print(f"🔍 Ищем серверы в каталоге {FOLDER_ID}...\n")

# 5. Делаем запрос на список серверов
instances = instance_service.List(ListInstancesRequest(folder_id=FOLDER_ID)).instances

if not instances:
    print("Серверов не найдено.")
else:
    for instance in instances:
        # Статусы в Яндексе приходят в виде чисел, переводим в текст
        status = "🟢 Работает" if instance.status == 2 else "🔴 Остановлен/Другое"
        print(f"Сервер: {instance.name}")
        print(f"ID: {instance.id}")
        print(f"Статус: {status}")
        print("-" * 30)
