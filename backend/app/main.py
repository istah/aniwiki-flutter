import os
from typing import Any, Dict, Optional

import httpx
from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

API_BASE = os.getenv("JIKAN_BASE_URL", "https://api.jikan.moe/v4")

_client: Optional[httpx.AsyncClient] = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global _client
    _client = httpx.AsyncClient(
        base_url=API_BASE,
        timeout=10.0,
        headers={"User-Agent": "AniWiki/0.1.0 (+fastapi)"},
    )
    try:
        yield
    finally:
        if _client:
            await _client.aclose()
            _client = None

app = FastAPI(title="AniWiki API", version="0.1.0", lifespan=lifespan)

# CORS: на проде укажи домен фронта (Firebase Hosting) в переменной окружения CORS_ORIGINS
origins_env = os.getenv("CORS_ORIGINS", "*").strip()
allow_origins = ["*"] if origins_env == "*" else [o.strip() for o in origins_env.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health() -> Dict[str, str]:
    return {"status": "ok"}


def _normalize_anime_item(item: Dict[str, Any]) -> Dict[str, Any]:
    images = item.get("images") or {}
    jpg = images.get("jpg") or {}
    return {
        "id": item.get("mal_id"),
        "title": item.get("title") or item.get("title_english") or item.get("title_japanese"),
        "image": jpg.get("image_url"),
        "score": item.get("score"),
        "year": item.get("year"),
        "type": item.get("type"),
        "episodes": item.get("episodes"),
        "genres": [g.get("name") for g in item.get("genres", [])],
    }


@app.get("/api/anime/search")
async def search_anime(
    q: str = Query("", description="Search query"),
    page: int = Query(1, ge=1),
    limit: int = Query(24, ge=1, le=25),
    sfw: bool = Query(True, description="Safe for work filter forwarded to Jikan"),
) -> Dict[str, Any]:
    """
    Прокси к Jikan /anime с унифицированной пагинацией.
    """
    global _client
    params = {"q": q, "page": page, "limit": limit, "sfw": str(sfw).lower()}

    try:
        r = await _client.get("/anime", params=params)
        r.raise_for_status()
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        detail = e.response.text
        if status == 404:
            raise HTTPException(status_code=404, detail={"code": "NOT_FOUND", "message": "Anime not found"})
        raise HTTPException(status_code=status, detail={"code": "UPSTREAM_ERROR", "message": detail})
    except httpx.HTTPError as e:
        raise HTTPException(status_code=502, detail={"code": "NETWORK_ERROR", "message": str(e)})

    payload = r.json() or {}
    items = [_normalize_anime_item(it) for it in payload.get("data", [])]
    pagination = payload.get("pagination") or {}

    return {
        "items": items,
        "page": pagination.get("current_page", page),
        "hasNext": bool(pagination.get("has_next_page")),
    }


@app.get("/api/anime/{anime_id}")
async def anime_detail(anime_id: int) -> Dict[str, Any]:
    """
    Детальная информация по аниме.
    Для MVP берём базовый /anime/{id}. При желании можно переключиться на /anime/{id}/full.
    """
    global _client
    try:
        r = await _client.get(f"/anime/{anime_id}")
        r.raise_for_status()
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        if status == 404:
            raise HTTPException(status_code=404, detail={"code": "NOT_FOUND", "message": "Anime not found"})
        raise HTTPException(status_code=status, detail={"code": "UPSTREAM_ERROR", "message": e.response.text})
    except httpx.HTTPError as e:
        raise HTTPException(status_code=502, detail={"code": "NETWORK_ERROR", "message": str(e)})

    data = (r.json() or {}).get("data") or {}
    images = data.get("images") or {}
    jpg = images.get("jpg") or {}
    trailer = data.get("trailer") or {}

    return {
        "id": data.get("mal_id"),
        "title": data.get("title") or data.get("title_english") or data.get("title_japanese"),
        "synopsis": data.get("synopsis"),
        "image": jpg.get("image_url"),
        "score": data.get("score"),
        "rank": data.get("rank"),
        "popularity": data.get("popularity"),
        "year": data.get("year"),
        "type": data.get("type"),
        "episodes": data.get("episodes"),
        "duration": data.get("duration"),
        "genres": [g.get("name") for g in (data.get("genres") or [])],
        "trailer": {
            "url": trailer.get("url"),
            "youtube_id": trailer.get("youtube_id"),
        },
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=int(os.getenv("PORT", "8000")), reload=True)