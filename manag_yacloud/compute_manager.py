import sys
import json
import logging
import argparse
import yandexcloud
from yandex.cloud.compute.v1.instance_service_pb2 import ListInstancesRequest, DeleteInstanceRequest
from yandex.cloud.compute.v1.instance_service_pb2_grpc import InstanceServiceStub

# Настройка логирования
logging.basicConfig(level=logging.INFO, format='%(asctime)s | %(levelname)-8s | %(message)s', datefmt='%H:%M:%S')

FOLDER_ID = 'b1gi80mvh2p8j0611ckc' # Вставь свой ID каталога

def get_sdk():
    with open('authorized_key.json') as infile:
        return yandexcloud.SDK(service_account_key=json.load(infile))

def list_vms(instance_service):
    logging.info("Запрашиваю список виртуальных машин...")
    instances = instance_service.List(ListInstancesRequest(folder_id=FOLDER_ID)).instances
    if not instances:
        logging.info("В каталоге нет виртуальных машин.")
        return

    print("\n--- Список серверов ---")
    for vm in instances:
        status = "🟢 Работает" if vm.status == 2 else ("🔴 Остановлен" if vm.status == 4 else f"🟡 Статус: {vm.status}")
        print(f"[{status}] Имя: {vm.name} | ID: {vm.id}")
    print("-----------------------\n")

def delete_vm(instance_service, vm_id):
    logging.warning(f"Инициирую удаление сервера {vm_id}...")
    try:
        operation = instance_service.Delete(DeleteInstanceRequest(instance_id=vm_id))
        logging.info(f"Команда на удаление отправлена. ID операции: {operation.id}")
    except Exception as e:
        logging.error(f"Ошибка при удалении: {e}")

def main():
    # Настраиваем чтение аргументов из консоли
    parser = argparse.ArgumentParser(description="Менеджер виртуальных машин Yandex Cloud")
    parser.add_argument('action', choices=['list', 'delete'], help="Действие: list (показать) или delete (удалить)")
    parser.add_argument('--id', help="ID сервера (обязателен для delete)", default=None)
    
    args = parser.parse_args()
    sdk = get_sdk()
    instance_service = sdk.client(InstanceServiceStub)

    if args.action == 'list':
        list_vms(instance_service)
    elif args.action == 'delete':
        if not args.id:
            logging.error("Для удаления необходимо указать ID сервера: --id <твой_id>")
            sys.exit(1)
        # Защита от случайного удаления
        confirm = input(f"ВЫ УВЕРЕНЫ, что хотите удалить сервер {args.id}? (yes/no): ")
        if confirm.lower() == 'yes':
            delete_vm(instance_service, args.id)
        else:
            logging.info("Удаление отменено.")

if __name__ == '__main__':
    main()