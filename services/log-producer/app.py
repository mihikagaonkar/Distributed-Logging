import json
import time
import uuid
from kafka import KafkaProducer
import random

producer = KafkaProducer(
    bootstrap_servers=['kafka:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)


def generate_log():
    level = random.choice(["INFO", "WARN", "ERROR"])
    message = {
        "INFO": "Order processed successfully",
        "WARN": "Order processing delayed",
        "ERROR": "Order processing failed due to payment timeout"
    }[level]

    return {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime()),
        "service": "orders",
        "level": level,
        "message": message,
        "order_id": str(uuid.uuid4())
    }


if __name__ == "__main__":
    print("Starting log producer...")
    while True:
        log = generate_log()
        producer.send('logs', log)
        producer.flush()
        print(f"Produced log: {log}")
        time.sleep(2)
