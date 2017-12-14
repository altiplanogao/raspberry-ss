# raspberry-ss
Using shadowsocks requires server setup and client setup.

This project helps you to setup a transparent proxy server in order to avoid client-side setup. (proxy server and clients shoud be on the same LAN)

## Requirements

* An existing shadowsocks server (a remote server has full www access, REMOTE_SERVER)
* Raspberry pi in same (a transparent proxy server, LOCAL_SERVER)
* Your computer/phone/pad ... (as clients, CLIENTS)

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

* Install applications:

  ```
  ./install-ss.sh
  ```

* Setup transparent proxy server: (Run as root)

  ```
  ./setup-transparent-proxy.sh
  ```

* Get the ip address (the transparent proxy server's address)

  ```
  ip addr
  ```

## Usage

* Option 1: (On your computer/phone/pad...)
  * Connect to the LAN.
  * Update gateway & dns's address, use LOCAL_SERVER's address.
* Option 2: (If you connect to the LAN use wifi, and you have access to the router )
  * Login to the router's web ui.
  * Update the gateway to LOCAL_SERVER.
  * Update the DNS to LOCAL_SERVER.