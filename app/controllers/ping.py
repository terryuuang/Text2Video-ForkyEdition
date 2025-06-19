from fastapi import APIRouter, Request

router = APIRouter()


@router.get(
    "/ping",
    tags=["Health Check"],
    description="檢查服務可用性",
    response_description="pong",
)
def ping(request: Request) -> str:
    return "pong"
