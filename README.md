Ran's working env
===

### Socks Proxy

shadowsocks. U know.

### HTTP Proxy

e.g

```conf
# /etc/privoxy/config
forward-socks / 127.0.0.1:1080 .
listen-address 127.0.0.1:1081
```

```sh
service privoxy restart
```

after that,

```sh
http_proxy=http://127.0.0.1:1081 wget google.com
curl --socks5 127.0.0.1:1080 google.com
```

### Container's accessibility

Well, here is a ssh solution.

For MacOS, u can access container by ssh tunnel:

```sh
# both host and container start sshd first

# inside host: make an alias for host
ifconfig lo0 alias <host-alias-ip>

# inside container
ssh -R <mapping-port-in-host>:localhost:<container-sshd-port> <host-alias-ip>
```

then,

```sh
# inside host
ssh <container>

# inside container
ssh <host>
```