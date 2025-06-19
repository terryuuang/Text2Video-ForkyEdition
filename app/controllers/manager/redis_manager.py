import json
from typing import Dict

import redis

from app.controllers.manager.base_manager import TaskManager
from app.models.schema import VideoParams
from app.services import task as tm

FUNC_MAP = {
    "start": tm.start,
    # 'start_test': tm.start_test
}


class RedisTaskManager(TaskManager):
    def __init__(self, max_concurrent_tasks: int, redis_url: str):
        self.redis_client = redis.Redis.from_url(redis_url)
        super().__init__(max_concurrent_tasks)

    def create_queue(self):
        return "task_queue"

    def enqueue(self, task: Dict):
        task_with_serializable_params = task.copy()

        if "params" in task["kwargs"] and isinstance(
            task["kwargs"]["params"], VideoParams
        ):
            task_with_serializable_params["kwargs"]["params"] = task["kwargs"][
                "params"
            ].dict()

        # 將函數物件轉換為其名稱
        task_with_serializable_params["func"] = self._serialize_func(task["func"])
        self.redis_client.rpush(self.queue, json.dumps(task_with_serializable_params))

    def dequeue(self):
        task_json = self.redis_client.lpop(self.queue)
        if task_json:
            task_info = json.loads(task_json)
            # 將函數名稱轉換回函數物件
            task_info["func"] = self._deserialize_func(task_info["func"])

            if "params" in task_info["kwargs"] and isinstance(
                task_info["kwargs"]["params"], dict
            ):
                task_info["kwargs"]["params"] = VideoParams(
                    **task_info["kwargs"]["params"]
                )

            return task_info
        return None

    def is_queue_empty(self):
        return self.redis_client.llen(self.queue) == 0

    def _serialize_func(self, func):
        # 將函數物件轉換為其名稱
        return func.__name__

    def _deserialize_func(self, func_name):
        # 將函數名稱轉換回函數物件
        if func_name in globals():
            return globals()[func_name]
        else:
            raise ValueError(f"Unknown function: {func_name}")
