import os
from typing import Any, Dict, List

import httpx
from flask import Flask, jsonify, request
from flask_cors import CORS

API_BASE = os.getenv("JIKAN_BASE_URL", "https://api.jikan.moe/v4")

# --- Flask app ---
app = Flask(__name__)

# CORS: set allowed origins from env, comma-separated; "*" for dev
origins_env = os.getenv("CORS_ORIGINS", "*").strip()
allow_origins: List[str]
if origins_env == "*":
    allow_origins = ["*"]
else:
    allow_origins = [o.strip() for o in origins_env.split(",") if o.strip()]

CORS(app, resources={r"/*": {"origins": allow_origins}}, supports_credentials=True)

# --- httpx client (sync) ---
_client: httpx.Client | None = None

def get_client() -> httpx.Client:
    global _client
    if _client is None:
        _client = httpx.Client(
            base_url=API_BASE,
            timeout=10.0,
            headers={"User-Agent": "AniWiki/0.1.0 (+flask)"},
        )
    return _client

@app.teardown_appcontext
def _close_client(exception: Exception | None) -> None:  # noqa: ARG001
    global _client
    if _client is not None:
        try:
            _client.close()
        finally:
            _client = None

# --- helpers ---

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

def _normalize_manga_item(item: Dict[str, Any]) -> Dict[str, Any]:
    images = item.get("images") or {}
    jpg = images.get("jpg") or {}
    return {
        "id": item.get("mal_id"),
        "title": item.get("title") or item.get("title_english") or item.get("title_japanese"),
        "image": jpg.get("image_url"),
        "score": item.get("score"),
        "year": item.get("year"),
        "type": item.get("type"),
        "chapters": item.get("chapters"),
        "volumes": item.get("volumes"),
        "genres": [g.get("name") for g in item.get("genres", [])],
    }

def _normalize_character_item(item: Dict[str, Any]) -> Dict[str, Any]:
    images = item.get("images") or {}
    jpg = images.get("jpg") or {}
    name = item.get("name") or ""
    return {
        "id": item.get("mal_id"),
        "name": name,
        "nicknames": item.get("nicknames") or [],
        "image": jpg.get("image_url"),
        "favorites": item.get("favorites"),
        "about": item.get("about"),
    }

# --- routes ---

@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok"}

# ---- Anime ----

@app.get("/api/anime/search")
def search_anime():
    q = request.args.get("q", default="")
    try:
        page = int(request.args.get("page", default="1"))
    except ValueError:
        page = 1
    try:
        limit = int(request.args.get("limit", default="24"))
    except ValueError:
        limit = 24
    sfw_raw = request.args.get("sfw", default="true").lower()
    sfw = "true" if sfw_raw in ("1", "true", "yes") else "false"

    params = {"q": q, "page": page, "limit": limit, "sfw": sfw}

    client = get_client()
    try:
        r = client.get("/anime", params=params)
        r.raise_for_status()
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        if status == 404:
            return jsonify(error={"code": "NOT_FOUND", "message": "Anime not found"}), 404
        return jsonify(error={"code": "UPSTREAM_ERROR", "message": e.response.text}), status
    except httpx.HTTPError as e:
        return jsonify(error={"code": "NETWORK_ERROR", "message": str(e)}), 502

    payload = r.json() or {}
    items = [_normalize_anime_item(it) for it in payload.get("data", [])]
    pagination = payload.get("pagination") or {}

    return jsonify({
        "items": items,
        "page": pagination.get("current_page", page),
        "hasNext": bool(pagination.get("has_next_page")),
    })

@app.get("/api/anime/<int:anime_id>")
def anime_detail(anime_id: int):
    client = get_client()
    try:
        r = client.get(f"/anime/{anime_id}")
        r.raise_for_status()
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        if status == 404:
            return jsonify(error={"code": "NOT_FOUND", "message": "Anime not found"}), 404
        return jsonify(error={"code": "UPSTREAM_ERROR", "message": e.response.text}), status
    except httpx.HTTPError as e:
        return jsonify(error={"code": "NETWORK_ERROR", "message": str(e)}), 502

    data = (r.json() or {}).get("data") or {}
    images = data.get("images") or {}
    jpg = images.get("jpg") or {}
    trailer = data.get("trailer") or {}

    return jsonify({
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
    })

# ---- Manga ----

@app.get("/api/manga/search")
def search_manga():
    q = request.args.get("q", default="")
    try:
        page = int(request.args.get("page", "1"))
    except ValueError:
        page = 1
    try:
        limit = int(request.args.get("limit", "24"))
    except ValueError:
        limit = 24

    params = {"q": q, "page": page, "limit": limit}
    client = get_client()
    try:
        r = client.get("/manga", params=params)
        r.raise_for_status()
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        if status == 404:
            return jsonify(error={"code": "NOT_FOUND", "message": "Manga not found"}), 404
        return jsonify(error={"code": "UPSTREAM_ERROR", "message": e.response.text}), status
    except httpx.HTTPError as e:
        return jsonify(error={"code": "NETWORK_ERROR", "message": str(e)}), 502

    payload = r.json() or {}
    items = [_normalize_manga_item(it) for it in payload.get("data", [])]
    pagination = payload.get("pagination") or {}

    return jsonify({
        "items": items,
        "page": pagination.get("current_page", page),
        "hasNext": bool(pagination.get("has_next_page")),
    })

@app.get("/api/manga/<int:manga_id>")
def manga_detail(manga_id: int):
    client = get_client()
    try:
        r = client.get(f"/manga/{manga_id}")
        r.raise_for_status()
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        if status == 404:
            return jsonify(error={"code": "NOT_FOUND", "message": "Manga not found"}), 404
        return jsonify(error={"code": "UPSTREAM_ERROR", "message": e.response.text}), status
    except httpx.HTTPError as e:
        return jsonify(error={"code": "NETWORK_ERROR", "message": str(e)}), 502

    data = (r.json() or {}).get("data") or {}
    images = data.get("images") or {}
    jpg = images.get("jpg") or {}
    return jsonify({
        "id": data.get("mal_id"),
        "title": data.get("title") or data.get("title_english") or data.get("title_japanese"),
        "synopsis": data.get("synopsis"),
        "image": jpg.get("image_url"),
        "score": data.get("score"),
        "rank": data.get("rank"),
        "popularity": data.get("popularity"),
        "year": data.get("year"),
        "type": data.get("type"),
        "chapters": data.get("chapters"),
        "volumes": data.get("volumes"),
        "genres": [g.get("name") for g in (data.get("genres") or [])],
    })

# ---- Characters ----

@app.get("/api/characters/search")
def search_characters():
    q = request.args.get("q", default="")
    try:
        page = int(request.args.get("page", "1"))
    except ValueError:
        page = 1
    try:
        limit = int(request.args.get("limit", "24"))
    except ValueError:
        limit = 24

    params = {"q": q, "page": page, "limit": limit}
    client = get_client()
    try:
        r = client.get("/characters", params=params)
        r.raise_for_status()
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        if status == 404:
            return jsonify(error={"code": "NOT_FOUND", "message": "Characters not found"}), 404
        return jsonify(error={"code": "UPSTREAM_ERROR", "message": e.response.text}), status
    except httpx.HTTPError as e:
        return jsonify(error={"code": "NETWORK_ERROR", "message": str(e)}), 502

    payload = r.json() or {}
    items = [_normalize_character_item(it) for it in payload.get("data", [])]
    pagination = payload.get("pagination") or {}

    return jsonify({
        "items": items,
        "page": pagination.get("current_page", page),
        "hasNext": bool(pagination.get("has_next_page")),
    })

@app.get("/api/characters/<int:char_id>")
def character_detail(char_id: int):
    client = get_client()
    try:
        r = client.get(f"/characters/{char_id}")
        r.raise_for_status()
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        if status == 404:
            return jsonify(error={"code": "NOT_FOUND", "message": "Character not found"}), 404
        return jsonify(error={"code": "UPSTREAM_ERROR", "message": e.response.text}), status
    except httpx.HTTPError as e:
        return jsonify(error={"code": "NETWORK_ERROR", "message": str(e)}), 502

    data = (r.json() or {}).get("data") or {}
    images = data.get("images") or {}
    jpg = images.get("jpg") or {}
    return jsonify({
        "id": data.get("mal_id"),
        "name": data.get("name"),
        "nicknames": data.get("nicknames") or [],
        "about": data.get("about"),
        "image": jpg.get("image_url"),
        "favorites": data.get("favorites"),
    })

if __name__ == "__main__":
    # Local dev run (not used on PythonAnywhere WSGI)
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8000")), debug=True)