import os
import sys

from loguru import logger

from app.config import config
from app.utils import utils


def __init_logger():
    # _log_file = utils.storage_dir("logs/server.log")
    _lvl = config.log_level
    root_dir = os.path.dirname(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    )

    def format_record(record):
        # 取得日誌記錄中的檔案完整路徑
        file_path = record["file"].path
        # 將絕對路徑轉換為相對於專案根目錄的路徑
        relative_path = os.path.relpath(file_path, root_dir)
        # 更新記錄中的檔案路徑
        record["file"].path = f"./{relative_path}"
        # 回傳修改後的格式字串
        # 您可以根據需要調整這裡的格式
        record["message"] = record["message"].replace(root_dir, ".")
        _format = (
            "<green>{time:%Y-%m-%d %H:%M:%S}</> | "
            + "<level>{level}</> | "
            + '"{file.path}:{line}":<blue> {function}</> '
            + "- <level>{message}</>"
            + "\n"
        )
        return _format

    logger.remove()

    logger.add(
        sys.stdout,
        level=_lvl,
        format=format_record,
        colorize=True,
    )

    # logger.add(
    #     _log_file,
    #     level=_lvl,
    #     format=format_record,
    #     rotation="00:00",
    #     retention="3 days",
    #     backtrace=True,
    #     diagnose=True,
    #     enqueue=True,
    # )


__init_logger()
