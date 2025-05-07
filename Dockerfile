# 使用官方 Python Runtime 作為基礎映像
FROM python:3.10-slim

#simulate a bug
THISWILLBREAKEDOCKERFILE

# 設定工作目錄
WORKDIR /app

# 複製需求文件並安裝依賴
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# 複製應用程式碼到工作目錄
COPY . .

# 開放應用程式運行的 Port
EXPOSE 5000

# 設定環境變數 (可以被 docker run -e 覆寫)
ENV NAME=Docker

# 容器啟動時運行的命令
CMD ["python", "app.py"]