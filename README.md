# CloudNative-HW4-Docker
B10303018 經濟四 汪晁安

## 如何建置 Docker Image (Build)

您可以使用以下指令在本機建置 Docker Image。請確保您已經安裝 Docker 並且在專案的根目錄下執行此指令。

```bash
# 將 your-dockerhub-id 替換成您的 Docker Hub ID (例如: andywang303018)
# 將 my-image-tag 替換成您想要的標籤 (例如: latest, v1.0, local-build)
docker build -t your-dockerhub-id/2025cloud:my-image-tag .
```
例如，若要建置一個名為 `local-dev` 的標籤：
```bash
docker build -t andywang303018/2025cloud:local-dev .
```

## 如何運行 Docker Container (Run)

您可以使用 `docker run` 指令來運行建置好的 Image 或直接從 Docker Hub 拉取已推送的 Image。

**選項 1: 運行本地建置的 Image**

假設您剛才建置的 Image 標籤是 `andywang303018/2025cloud:local-dev`：
```bash
# -d: 在背景運行容器
# -p 5001:5000: 將主機的 5001 port 映射到容器的 5000 port
#    (使用 5001 是為了避免和您本機直接跑 python app.py 的 5000 port 衝突)
# --name my-app-container: 為容器命名，方便管理
# --rm: 容器停止後自動刪除 (方便測試)
docker run -d -p 5001:5000 --name my-local-app --rm andywang303018/2025cloud:local-dev
```
運行後，您可以透過瀏覽器訪問 `http://localhost:5001` 來查看應用程式。

**選項 2: 直接運行 Docker Hub 上的 Image**

例如，運行您之前手動推送到 Docker Hub 的 `v0.1` 標籤 (請將 `your-dockerhub-id` 替換掉，例如 `andywang303018`)：
```bash
docker run -d -p 5002:5000 --name my-dockerhub-manual-app --rm your-dockerhub-id/2025cloud:v0.1
```
或者運行由 GitHub Action 自動推送的 `latest` 標籤：
```bash
docker run -d -p 5003:5000 --name my-dockerhub-latest-app --rm your-dockerhub-id/2025cloud:latest
```
運行後，您可以透過瀏覽器分別訪問 `http://localhost:5002` 或 `http://localhost:5003`。

**選項 3: 運行時傳遞環境變數**

您可以透過 `-e` 或 `--env` 來設定環境變數，例如改變問候的名字：
```bash
# 從 Docker Hub 拉取 latest 標籤，並設定 NAME 環境變數
docker run -d -p 5004:5000 --name my-custom-app --rm -e NAME="Cloud Master" your-dockerhub-id/2025cloud:latest
```
運行後，您可以透過瀏覽器訪問 `http://localhost:5004` 查看，問候語應該會改變。

**停止和移除容器:**

如果您沒有使用 `--rm` 選項，容器會在停止後保留。
```bash
# 停止容器 (使用您為容器設定的 --name)
docker stop my-local-app
docker stop my-dockerhub-manual-app
# ...等等

# 移除已停止的容器 (如果您沒有用 --rm)
docker rm my-local-app
```
若要一次停止並移除所有正在運行的範例容器 (請小心使用，確認沒有其他重要容器也叫類似名字)：
```bash
docker ps -a --filter "name=my-" -q | xargs --no-run-if-empty docker stop
docker ps -a --filter "name=my-" -q | xargs --no-run-if-empty docker rm
```

## GitHub Action 自動化與標籤策略

本專案已整合 GitHub Actions，以自動化 Docker Image 的建置、測試與推送流程。

**Workflow 觸發條件：**

1.  **Push to `master` branch**: 當有任何新的 commit 被推送到 `master` 分支時 (請確認您的主要分支名稱，若非 `master` 請替換)，Workflow 會自動觸發。
2.  **Pull Request to `master` branch**: 當有新的 Pull Request 被建立且目標是 `master` 分支，或現有 Pull Request 有更新時，Workflow 也會觸發。

**自動化流程邏輯：**

* **當事件為 Push to `master` branch:**
    1.  **Checkout Code**: 拉取 `master` 分支最新的程式碼。
    2.  **Login to Docker Hub**: 使用預存在 GitHub Secrets 中的 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_TOKEN` 登入 Docker Hub。
    3.  **Build and Push Image**:
        * 使用專案中的 `Dockerfile` 建置 Docker Image。
        * 將建置好的 Image 推送到 Docker Hub 的 `your-dockerhub-id/2025cloud` Repository (例如 `andywang303018/2025cloud`)。

* **當事件為 Pull Request to `master` branch:**
    1.  **Checkout Code**: 拉取 Pull Request 中的程式碼變更。
    2.  **Build Image (No Push)**:
        * 使用專案中的 `Dockerfile` (包含 PR 中的修改) 建置 Docker Image。
        * **此步驟不會推送 Image 到 Docker Hub**。其主要目的是驗證 `Dockerfile` 及相關程式碼是否能夠成功建置，作為 Pull Request 合併前的檢查。如果建置失敗，會在 PR 頁面顯示錯誤。

**Image Tag 設計與選擇邏輯 (針對 Push to `master` branch)：**

當成功建置並推送到 Docker Hub 時 (即 Push to `master` branch 的情況)，會使用以下兩種標籤：

1.  `latest`: 此標籤永遠指向 `master` 分支上最新一次成功建置並推送的 Image。方便使用者或部署系統總是能取得最新的穩定版本。
    * 例如：`andywang303018/2025cloud:latest`
2.  `<commit-sha>`: 使用觸發此次 Workflow 的 Git Commit 的完整 SHA 值作為標籤。這提供了一個精確的版本追溯方式，讓每一個推送到 Docker Hub 的 Image 都能明確對應到某一次特定的程式碼提交。
    * 例如：`andywang303018/2025cloud:e7bd623dc761c2e2fd957b8b485d4f8b94dc2c09` (此處 SHA 為範例)

這樣的標籤策略結合了易用性 (`latest`) 和版本控制的精確性 (`<commit-sha>`)。
