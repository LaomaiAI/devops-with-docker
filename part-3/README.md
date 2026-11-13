# DevOps with Docker — Part 3（Security and optimization）

課程：赫爾辛基大學 DevOps with Docker，Fall 2026，課程平台第 4 章。
倉庫：https://github.com/LaomaiAI/devops-with-docker，分支 main。

## 練習一覽

| 練習 | 內容 | 交付物 |
| --- | --- | --- |
| 3.1 | 部署流程：express-app 推送至 Docker Hub | 3_1/express-app、.github/workflows/deploy-express.yml |
| 3.2 | 部署流程：後端部署至雲端 Render | .github/workflows/deploy-render.yml、3_2/README.md |
| 3.3 | 撰寫 builder.sh | 3_3/builder.sh |
| 3.4 | 將 builder 容器化 | 3_4/Dockerfile、3_4/builder.sh |
| 3.5 | 非 root 容器 | 3_5/Dockerfile.frontend、3_5/Dockerfile.backend |
| 3.6 | 合併 RUN、精簡映像 | 3_6/Dockerfile.frontend、3_6/Dockerfile.backend |
| 3.7 | 預裝環境映像 | 3_7/Dockerfile.frontend、3_7/Dockerfile.backend |
| 3.8 | 多階段前端 | 3_89/Dockerfile.frontend |
| 3.9 | 多階段後端（scratch） | 3_89/Dockerfile.backend |
| 3.10 | .dockerignore | 根目錄 .dockerignore、本文件 3.10 一節 |
| 3.11 | Kubernetes 圖表 | part-3/kubernetes-diagram.drawio、part-3/kubernetes-diagram.svg |
| 3.12 | 提交倉庫連結與自評 | 本倉庫連結（課程平台提交） |

應用程式原始碼（官方範本）位於 code/example-frontend 與 code/example-backend，
與倉庫內 example-app 的原始碼相同，Dockerfile 則分別放在各練習目錄。
所有 Dockerfile 都以倉庫根目錄為建置上下文，例如：

```
docker build -f 3_5/Dockerfile.frontend -t my-frontend .
```
## 3.1 部署流程：express-app

來源：https://github.com/docker-hy/material-applications 內的 express-app，
複製至 3_1/express-app，並將首頁訊息改為 Hello World from DevOps with Docker Part 3!，
以便驗證新版本已部署。

流程檔案：.github/workflows/deploy-express.yml。
每次推送至 main 且改動 3_1/express-app 或該流程檔案時，
GitHub Actions 會登入 Docker Hub 並建置推送 laomaiai/express-app:latest。

所需倉庫 Secrets：DOCKERHUB_USERNAME、DOCKERHUB_TOKEN。
本機驗證：建置映像後以 docker run 啟動，GET http://localhost:8080 回傳新訊息。

## 3.2 部署流程：雲端 Render

已部署應用程式：https://devops-docker-backend.onrender.com/ping（Render 免費方案，
服務名稱 devops-docker-backend，映像 laomaiai/example-backend:latest）。

流程檔案：.github/workflows/deploy-render.yml。
每次推送至 main 且改動 example-app/backend 或該流程檔案時，
GitHub Actions 會重新建置並推送 laomaiai/example-backend:latest，
再以 curl 呼叫 Render 部署掛鉤（Secret RENDER_DEPLOY_HOOK_URL）觸發重新部署。

所需倉庫 Secrets：DOCKERHUB_USERNAME、DOCKERHUB_TOKEN、RENDER_DEPLOY_HOOK_URL。
驗證：推送後在 Render 檢查有新的部署，GET /ping 回傳 pong。

## 3.3 builder.sh

檔案：3_3/builder.sh，參數為 GitHub 倉庫（例如 mluukkai/express_app）及 Docker Hub 倉庫
（例如 mluukkai/testing），依序執行：git clone、docker build、docker login、docker push。
密碼由環境變數 DOCKER_PASSWORD 或 DOCKER_PWD 提供，以 --password-stdin 登入，
不寫在命令列。少於兩個參數時結束並回傳非零狀態碼。

## 3.4 將 builder 容器化

檔案：3_4/Dockerfile（基礎映像 docker:27-cli，安裝 git 與 bash）及 3_4/builder.sh
（與 3_3/builder.sh 內容相同，因為建置上下文是 3_4 目錄本身）。
ENTRYPOINT 直接執行 builder.sh。用法：

```
docker build -t builder 3_4
docker run -e DOCKER_USER=laomaiai -e DOCKER_PWD=xxx -v /var/run/docker.sock:/var/run/docker.sock builder mluukkai/express_app mluukkai/testing
```
## 3.5 非 root 用戶執行

在 3_5/Dockerfile.frontend（ubuntu:22.04）及 3_5/Dockerfile.backend（golang:1.16）
末尾加入 USER appuser，容器以 uid 1000 執行。
前端以 useradd 建立 appuser，後端同樣；Alpine 映像則用 adduser -D（沒有 useradd）。
前端以變數 REACT_APP_BACKEND_URL=http://localhost:8080 建置，
後端以環境變數 REQUEST_ORIGIN=http://localhost:5001 執行，
前端按 backend 按鈕可成功呼叫後端。

## 3.6 合併 RUN、精簡映像

基礎映像不變（前端 ubuntu:22.04、後端 golang:1.16）。
前端所有安裝與建置步驟合併為一個 RUN：apt 安裝、安裝 Node.js、npm install、
npm run build、安裝 serve、刪除 src、建立 appuser、chown、apt-get clean 及刪除 apt 清單。
後端同樣合併為一個 RUN，並刪除 Go 建置快取與模組下載快取。

## 3.7 預裝環境映像

前端改用 node:16-alpine，後端改用 golang:1.24-alpine；
兩者都不再需要 apt-get 或 nodesource 安裝程式，Node.js 16 是前端程式所需版本。

## 3.8 多階段前端、3.9 多階段後端

3_89/Dockerfile.frontend：第一階段 node:16-alpine 建置靜態檔案，
第二階段 node:16-alpine 只安裝 serve 並複製 build 成果，不複製原始碼，不再執行 npm install 或 npm run build。
3_89/Dockerfile.backend：第一階段 golang:1.24-alpine 以 CGO_ENABLED=0、-trimpath 及 -ldflags -s -w
編譯靜態執行檔，第二階段 FROM scratch 只複製該執行檔，以 USER 10001 執行。

## 映像大小（本機實測，docker images）

| 映像 | 原始（1.12／1.13） | 3.5 非 root | 3.6 精簡 | 3.7 Alpine | 3.89 多階段 |
| --- | --- | --- | --- | --- | --- |
| 前端 | 1.17GB | 1.64GB | 1.07GB | 961MB | 192MB |
| 後端 | 1.54GB | 1.57GB | 1.47GB | 769MB | 20MB |

3.5 前端較原始大，是因為 chown 整個應用程式目錄多了一層；
3.6 合併 RUN 並刪除 src 及 apt 清單後已回復並低於原始大小。
3.9 後端 20MB，低於練習要求的 25MB。
## 3.10 .dockerignore

根目錄 .dockerignore 已加入以下內容：.git、.github、tests、node_modules、*.log、
.env 與 .env.*、.npmrc、*.pem、*.key、*.sql、*.gz、backup、documentation、dist、
.vscode、.idea、.DS_Store。
建置上下文是倉庫根目錄時，這些檔案不會被 COPY 進映像。

以 devopsdockeruh/dockerignore_exercise 映像實測：其 .dockerignore 是空的（0 位元組），
因此 .git（完整提交紀錄，含作者姓名與電郵）、含 API_KEY 與 SECRET 的 .env、
backup 內的資料庫傾印、.github 的工作流程，以及 90MB 的 node_modules 都被裝進映像。
.gitignore 本身已列出 node_modules、dist、*.log、.env 等項目，.dockerignore 應至少照抄該清單，
再加 .git、.env*、密碼與金鑰、備份與資料傾印；預設亦應排除機密、憑證、
node_modules 與建置產物。

## 3.11 Kubernetes 圖表

檔案：part-3/kubernetes-diagram.drawio（draw.io 可編輯版本）及
part-3/kubernetes-diagram.svg（同一圖表的檢視版本）。
圖表包含：我的電腦（kubectl）、互聯網 HTTP 要求、Kubernetes Cluster（控制平面及三台
Worker Node 主機）、兩個應用程式 example-frontend（Node.js，連接埠 5001）與
example-backend（Go，連接埠 8080，含一個副本）、
Service（frontend-service 為 NodePort、backend-service 為 ClusterIP）、
Volume（PersistentVolumeClaim），以及叢集外的 PostgreSQL 資料庫／外部 API。
圖中標註了 Pod、Cluster、Container、Service、Volume 共五個術語。

## 3.12 提交

提交倉庫連結：https://github.com/LaomaiAI/devops-with-docker
本文件即為提交說明；課程平台 3.12 題填寫該連結並完成自評。

## 測試方法

使用官方範本倉庫 docker-hy/exercises-security-and-optimization 內的測試腳本，
已複製至倉庫 tests/test_3_03_builder_script.sh 至 tests/test_3_09_multistage_backend.sh，
並由 .github/workflows/tests.yml 在每次推送時自動執行全部測試。
本機以 bash tests/test_3_*.sh 逐題執行，2026 年 11 月 13 日全部通過：

3.03 builder script：通過（參數檢查、clone、build、login、push 順序正確）。
3.04 dockerized builder：通過（映像建置、ENTRYPOINT、clone、build、login、push 順序正確）。
3.05 non-root Dockerfiles：通過（前後端以 uid 1000 執行，前端 backend 按鈕顯示成功）。
3.06 optimized images：通過（前端一個 RUN、不含 src、後端不含快取）。
3.07 prebuilt images：通過（node:16-alpine、golang:1.24-alpine）。
3.08 multistage frontend：通過（兩階段，最終階段只複製 build 成果並以非 root 執行）。
3.09 multistage backend：通過（兩階段、最終階段 FROM scratch、靜態執行檔、前端連接埠 5001）。
3.09 映像在加入 -ldflags -s -w 後重測仍通過，大小為 20MB。

## AI 使用須知

部分練習使用了 AI 工具輔助。
