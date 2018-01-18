# raspberry-ss
在树莓派上配置一个透明代理 (使用 shadowsocks & chinadns)

## 简介
使用shadowsocks (SS)需要服务端的设置和客户端的设置。
* SS 服务端步骤: (运行在一个没有网络访问限制的远程服务器上)
  * 安装SS服务
  * 配置（加密方法、密码、端口 ...）并启动
* SS 客户端步骤: (运行在智能终端上, 如：电脑、手机、平板电脑)
  * 安装SS客户端
  * 配置SS客户端并启动
  * 配置应用代理（使其指向SS客户端的服务端口）。应用有很多：浏览器、程序、脚本。有些工具配置起来非常麻烦，有些工具干脆就不提供配置选项。

对每台设备的配置都是必不可少的。好在某些SS客户端可以共享连接，但是应用代理的配置依然必须。

如果我们建立一个透明代理，在透明代理后面运行SS客户端，那么我们甚至可以完全避免智能终端上的配置。

我们将在一台树莓派（p3 b型，官方操作系统Raspbian）上配置一个这样的透明代理，并把它当网关使用。

## 环境
假设你有很多智能设备：电脑、智能手机、平板电脑。它们都通过同一个路由器上网。

另外，你需要一台SS服务器。 (详细配置过程不在此讨论)

## 步骤

### 树莓派上:

* 克隆代码:

  ```
  git clone https://github.com/altiplanogao/raspberry-ss.git
  ```

* 配置SS服务器的连接信息:

  ```
  cp config .config
  vi .config
  ```

* 通过脚本安装SS服务 (shadowsocks_libev & chinadns):

  ```
  ./install-ss.sh
  ```

* 配置透明代理(修改iptables): (Run as root)

  ```
  ./setup-transparent-proxy.sh
  ```

* 获取ip. (记为 RASPBERRY_IP)

  ```
  ip addr
  ```

## 使用

* 方法 1: (智能设备上...)
  * 连接网络.
  * 配置网关和DNS地址，指向${RASPBERRY_IP}.
* 方法 2: (如果你有路由器修改权限的话)
  * 登陆路由器管理网页
  * 配置网关和DNS地址，指向${RASPBERRY_IP}.
 
 推荐使用方法2, 这样的话，智能设备只要连上这台路由器就能直接使用SS服务，而不需要任何配置.

# raspberry-ss
Setup transparent proxy server (use shadowsocks & chinadns) on raspberry pi

## intro
Using shadowsocks (SS) requires server setup and client setup.
* SS server steps: (Run on a remote machine with full www access)
  * Install SS service
  * Config SS (encryption, password, port ...), and launch
* SS client steps: (Run on smart devices, e.g., computer, mobile phone, pad, smart tv)
  * Install the SS client
  * Config the client and launch
  * Config the application's proxy to point to the SS client's service port. Applications are varied, a browser, a tool runs in command line, a script. For some tools, proxy setting is hard. And there are tools without proxy setting option even more. 

Generally, client configuration is required for every device. (although you may share SS service from a device, but proxy setting is still required)

Suppose we have a transparent proxy server, and run SS client in backgound, then, no more device side setting is required.

This project will help you to setup a transparent proxy server on raspberry pi 3. And run it as gateway

NOTE: only tested on raspberry pi 3 model b (with official os: Raspbian). 

## Environment
Suppose you have smart devices, e.g., computers, smart phones, pads. Devices connet to the internet through a same router.

And, you need an working SS server. (detailed setup steps are not inclued here)

## Steps

### On your raspberry:

* Clone repository:

  ```
  git clone https://github.com/altiplanogao/raspberry-ss.git
  ```

* Input shadowsocks server information:

  ```
  cp config .config
  vi .config
  ```

* Install applications (shadowsocks_libev & chinadns): 

  ```
  ./install-ss.sh
  ```

* Setup transparent proxy server (update iptables): (Run as root)

  ```
  ./setup-transparent-proxy.sh
  ```

* Get the ip address for further steps. (call it RASPBERRY_IP)

  ```
  ip addr
  ```

## Usage

* Method 1: (On your smart devices...)
  * Connect to the LAN.
  * Update gateway & dns's address, use value: ${RASPBERRY_IP}.
* Method 2: (If have access to the router)
  * Login to the router's web ui.
  * Update gateway & dns's address, use value: ${RASPBERRY_IP}.
 
 Method 2 is recommended, because no any device side configuration required.
 

