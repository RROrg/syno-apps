# syno-apps

## 简介

| name | desc |
|---------|---------|
| chromium-desktop | Chromium-based desktop browser running as a Docker container, based on wjz304/chromium-desktop. |
| kodi | Kodi media center running as a Docker container, based on wjz304/kodi. |
| terminal | Windowed terminal for Synology NAS, based on ttyd & tmux. |

## 安装方法
1. 在套件中心手动安装 `syno-<package>.spk`
2. 安装失败后，按提示 SSH 登录 DSM，执行：
   ```sh
   sudo sed -i 's/package/root/g' /var/packages/<package>/conf/privilege
   sudo synopkg restart <package>
   ```
3. 通过 icon 启动窗口 或者 通过浏览器访问：`http(s)://<ip>:<port>/<package>/`


## Sponsoring

- <img src="https://raw.githubusercontent.com/wjz304/wjz304/master/my/buymeacoffee.png" width="700">

## License

- [GPL-V3](https://github.com/RROrg/fn-apps/blob/main/LICENSE)
