# DevOps with Docker — Part 1（练习 1.1–1.16）

课程：赫尔辛基大学 DevOps with Docker，Fall 2026 实例（courses.mooc.fi）。
本仓库基于课程官方练习模板 docker-hy/exercises-docker-basics，1.7–1.16 的交付物位于 1_07–1_16 目录；1.1–1.6 为平台填空/文字题，答案记录于下方，尚未在平台提交。

## 完成情况

- 练习 1.1–1.16 全部完成并在本地验证通过。
- 1.15 与 1.16 均完成（课程要求两者至少完成其一）。
- 练习 0.1 与 1.17（提交本仓库链接）尚未在课程平台提交。

## 1.1–1.6 平台题目答案（备查，供在课程平台手动填入）

- 1.1 Getting started：启动两个 nginx 容器（docker run -d nginx，容器名 ex11-a、ex11-b），停止其中一个（docker stop ex11-b），再执行 docker ps -a。
- 1.2 Cleanup：docker stop f1f；docker rm e69 f1f；docker rmi nginx。
- 1.3 Secret message：先运行 docker run -d --name ex13 devopsdockeruh/simple-web-service:ubuntu，再 docker exec -it ex13 bash，随后 tail -f ./text.log；秘密消息为 "You can find the source code here: https://github.com/docker-hy"。
- 1.4 Missing dependencies：docker run -it ubuntu sh -c '...'；docker exec -it be3 bash；apt-get update；apt-get install -y curl。
- 1.5 Sizes of images：alpine 24.3 MB，ubuntu 126 MB（docker image ls 的磁盘占用；内容大小分别为 7.93 MB 与 33.7 MB）。
- 1.6 Hello Docker Hub：秘密消息为 "This is the secret message"（镜像 devopsdockeruh/pull_exercise，密码为 basics）。

## 1.7–1.14 交付物

- 1_07：Dockerfile（ubuntu:24.04，安装 curl，复制 script.sh 并设为默认命令）与 script.sh；镜像名 curler。
- 1_08：Dockerfile（FROM devopsdockeruh/simple-web-service:alpine，CMD ["server"]）与 commands；镜像名 web-server。
- 1_09：commands（先 touch service.log，再把宿主文件 bind mount 到容器的 /usr/src/app/text.log）。
- 1_10：commands（docker run -d -p 8080:8080 web-server）。
- 1_11：Dockerfile（amazoncorretto:8，Maven 构建）与 commands；镜像名 spring-example。
- 1_12：Dockerfile（ubuntu:22.04，Node 16.x，serve）与 commands；http://localhost:5001 显示 "Congratulations! You configured your ports correctly!"。
- 1_13：Dockerfile（golang:1.16）与 commands；GET http://localhost:8080/ping 返回 pong。
- 1_14：Dockerfile.frontend、Dockerfile.backend 与 commands；前端按钮变绿（本地测试用 Playwright 验证通过）。

## 1.15 Docker Hub

- 账号：laomaiai（hero372121@gmail.com），免费 Personal 套餐。
- 镜像仓库：https://hub.docker.com/r/laomaiai/example-backend（公开，tag latest，digest sha256:45e33447ad09d9bcd0fe0c64288e14150c96f918838dcd1959ebae3ebd78bd51）。
- 1_15/repository 内容：laomaiai/example-backend。

## 1.16 云部署（Render）

- 服务：devops-docker-backend（免费套餐，区域 Oregon，美国西部），健康检查路径 /ping。
- 链接：https://devops-docker-backend.onrender.com/ping，GET /ping 返回 pong（HTTP 200）。
- 1_16/answer 含上述链接与说明。

## 本地测试

在 tests/ 目录运行课程官方测试脚本，例如：bash test_1_07_curler.sh。
1.07–1.16 全部通过（All tests passed）。推送后 GitHub Actions 也会运行同样的 9 组测试。

## 关于 AI 工具的使用

课程要求学生主导完成练习，并在提交时说明 AI 的使用方式。请勿提交自己无法逐行解释的配置。
