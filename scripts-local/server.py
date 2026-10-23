# -*- coding: utf-8 -*-
"""本地静态服务器 + 实时数据抓取
- 托管网站静态文件（默认端口 8899，被占用自动顺延至 8999）
- 后台每 60 秒自动抓取竞彩实时赔率/比分/状态，写入 data/matches.json
"""
import http.server
import socketserver
import os
import sys
import threading
import time
import webbrowser

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(PROJ, "scripts"))
os.chdir(PROJ)

import fetch_data  # noqa: E402

PORT_START = 8899
PORT_END = 8999
REFRESH_INTERVAL = 60  # 秒


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        if self.path.split("?")[0].endswith(".json"):
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
        super().end_headers()

    def log_message(self, *args):
        pass


class ReusableServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


def refresher():
    while True:
        try:
            fetch_data.refresh_matches()
        except Exception as e:
            print("[刷新错误] %s" % e)
        time.sleep(REFRESH_INTERVAL)


def main():
    os.chdir(PROJ)
    threading.Thread(target=refresher, daemon=True).start()

    httpd = None
    port = PORT_START
    for p in range(PORT_START, PORT_END + 1):
        try:
            httpd = ReusableServer(("127.0.0.1", p), Handler)
            port = p
            break
        except OSError:
            continue
    if httpd is None:
        print("8899-8999 端口均被占用，请关闭占用程序后重试。")
        time.sleep(8)
        return

    url = "http://127.0.0.1:%d/index.html" % port
    print("=" * 52)
    print("   足球竞彩 AI 分析系统 已启动")
    print("   访问地址: %s" % url)
    print("   比赛数据每 %d 秒自动刷新（实时比分/状态/赔率）" % REFRESH_INTERVAL)
    print("   关闭此窗口即停止服务")
    print("=" * 52)
    threading.Timer(1.2, lambda: webbrowser.open(url)).start()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
