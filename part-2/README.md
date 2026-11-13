# Part 2 — Docker Compose

赫爾辛基大學 DevOps with Docker（Fall 2026）第二部分，對應課程平台 Chapter 3「Docker compose」，練習 2.1–2.11（2.11 為選做練習），以及 2.12 倉庫提交與自評。

部分練習使用了 AI 工具輔助。

## 答案總覽

| 練習 | 交付物 | 要點 |
| --- | --- | --- |
| 2.1 | 2_01/docker-compose.yaml | simple-web-service，不加 command（預設只寫日誌）；bind mount `./log.txt:/usr/src/app/text.log`，日誌寫入工作區的 log.txt |
| 2.2 | 2_02/docker-compose.yaml | 加上 `command: server` 才啟動 HTTP 伺服器；`ports: "8080:8080"`，瀏覽器可開啟 http://localhost:8080/ |
| 2.3 | 2_03-10/docker-compose.yaml | 前端（`serve`，5001）與後端（Go，8080）同一個 compose 檔案 |
| 2.4 | 同上 | 加入 Redis，後端設 `REDIS_HOST=redis`；Redis 不發布端口 |
| 2.5 | 見下文「練習 2.5」 | 用 `docker compose up -d --scale compute=3` 擴展 compute 容器 |
| 2.6 | 同上 | 加入 `db` 服務（postgres:16），後端設 `POSTGRES_HOST=db` 等環境變數 |
| 2.7 | 同上 | bind mount `./database:/var/lib/postgresql/data`，資料持久化到工作區 |
| 2.8 | 2_03-10/nginx.conf + compose | Nginx 反向代理，唯一發布的端口是 `8000:80`；`/` 往前端 5001，`/api/` 往後端 8080 |
| 2.9 | example-app/frontend/Dockerfile + compose | 前端不再設定 REACT_APP_BACKEND_URL，改用預設的 `/api` 經 Nginx 同源呼叫後端 |
| 2.10 | 同上 | 只有 nginx 發布端口，其餘服務只用 `expose`，不直接對外開放 |
| 2.11（選做） | 2_11/docker-compose.yaml | example-app 的容器化開發環境（見下文） |

## 練習 2.5（縮放）

使用的命令（在 docker-hy/material-applications 倉庫的 scaling-exercise 目錄內執行）：

```
git clone https://github.com/docker-hy/material-applications.git
cd material-applications/scaling-exercise
docker compose up -d --scale compute=3
```

原理與驗證：計算器每次計算需時 3–4 秒，測試要在 30 秒內完成 10 次並行計算。1 個 compute 約需 35 秒，不合格；3 個 compute 時，在 Codespace 內直接量度，10 次並行請求共耗時約 15.2 秒，通過 30 秒上限。

## 2_03-10 堆疊的關鍵設定

- 後端監聽 8080（預設），前端 `serve` 監聽 5001；後端環境變數：`REDIS_HOST=redis`、`POSTGRES_HOST=db`、`POSTGRES_USER=postgres`、`POSTGRES_PASSWORD=postgres`、`POSTGRES_DATABASE=postgres`、`REQUEST_ORIGIN=http://localhost:8000`。
- 資料庫服務名稱是 `db`（課程範例的命名；官方測試 2.10 會檢查 `db` 服務不發布端口）。
- Postgres 固定用 `postgres:16`：未指定版本的 `postgres:latest` 已是 PG 18，其映像拒絕把資料目錄直接掛載到 `/var/lib/postgresql/data`（會啟動失敗，錯誤訊息要求掛載到 `/var/lib/postgresql`）。用 PG 16 可按課程做法掛載 `./database`，行為確定。
- Nginx（2_03-10/nginx.conf）：`location /` 代理到 `http://frontend:5001`；`location /api/` 代理到 `http://backend:8080/`（注意尾隨斜線，Nginx 會剝除 `/api` 字首，後端實際收到 `/ping` 等路徑）。
- 2.9 的修復：前端 Dockerfile 不再設定 `REACT_APP_BACKEND_URL`；前端程式碼預設以 `/api` 為基底（`frontend/src/util/pingpong.js`），經 Nginx 同源呼叫後端，所以後端端口關閉後按鈕仍可運作。
- 2.10：唯一發布的端口是 nginx 的 `8000:80`；backend、frontend、redis、db 只用 `expose`，不設 `ports`。

## 練習 2.11（選做）：容器化開發環境

2_11/docker-compose.yaml 為 example-app 的開發環境：

- `frontend-dev`：node:16，原始碼 bind mount 到容器（改動即時生效，React 開發伺服器熱重載），`node_modules` 用匿名卷保留在容器內避免被掛載覆蓋；`npm install && npm start`，端口 3000。
- `backend-dev`：由 example-app/backend 建置，端口 8080；`REQUEST_ORIGIN=http://localhost:3000`（開發伺服器的來源）。
- `redis-dev`、`db-dev`（postgres:16，資料 bind mount 到 `./database`）供開發時使用，後端以 `redis-dev`、`db-dev` 作為主機名稱連接。


## 測試方法與結果

課程官方測試（由 docker-hy/exercises-docker-compose 範本複製到 tests/，CI 工作流程已加入這 9 項）：

```
bash tests/run_all_part2.sh
```

2026 年 11 月 13 日在 Codespace 本地執行，9 個測試全部通過（EXIT=0）：test_2_01_writing_to_log、test_2_02_simple_server_with_browser、test_2_03_project_compose、test_2_04_project_redis、test_2_06_project_postgres、test_2_07_project_bind_mount、test_2_08_project_nginx_basic、test_2_09_project_nginx、test_2_10_project_closed_ports。

其中 2.03、2.04、2.06、2.07 在 compose 已含 nginx 時由 2.09/2.10 覆蓋（測試本身會跳過直接檢查），設計如此。

手動驗證（2_03-10 堆疊啟動後）：

- `curl http://localhost:8000/` 回 200（前端頁面）；`curl http://localhost:8000/api/ping` 回 `pong`。
- `curl "http://localhost:8000/api/ping?redis=true"` 回 `pong`；`curl "http://localhost:8000/api/ping?postgres=true"` 回 `pong`。
- `POST /api/messages` 後 `GET /api/messages` 列出已儲存的訊息。
- 2.7 持久化：`docker compose down` 後再 `up`，訊息仍在；刪除 `2_03-10/database` 後再 `up`，訊息消失。
- 2.11 開發環境：前端開發伺服器 http://localhost:3000 回 200，後端 http://localhost:8080/ping 回 `pong`。

## 倉庫內主要新增檔案

- `2_01/docker-compose.yaml`、`2_02/docker-compose.yaml
- `2_03-10/docker-compose.yaml`、`2_03-10/nginx.conf
- `2_11/docker-compose.yaml
- `example-app/`（課程範本的 example-backend 與 example-frontend 來源，另加兩份 Dockerfile：`example-app/backend/Dockerfile`、`example-app/frontend/Dockerfile`）
- `tests/test_2_*.sh`、`tests/run_all_part2.sh
- `.github/workflows/tests.yml`（矩陣加入 9 個 Part 2 測試；Part 1 測試不變）
- `.gitignore`（新增 `2_01/log.txt`、`2_03-10/database/`、`2_11/database/`，資料庫資料與日誌檔不進倉庫）

## 備註

- 2.5 的 scaling-exercise 不在本科目錄內提交（按練習要求只在平台交回所用命令），已停止相關容器。
- 首次啟動後端時若資料庫未就緒，後端只會在程序啟動後的首次 Postgres 初始化時重試；更換資料庫後請重啟後端容器。
