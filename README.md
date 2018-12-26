
### What is this ?
Docker container based on CentOS 7, NGINX and PHP-FPM 7 with compatible version and modules for Wordpress

Inspired by [locnh/docker-wordpress](https://github.com/locnh/docker-wordpress)

### Main features:
 - provides isolated PHP environment with hardened (secured) nginx configuration for Wordpress.  
 - optional SSHD, can be started with extra environment keys. Default user `www-user`, no default password - re-generates if not set.
 - starts the extra HTTPS with fresh-generated ECC certificates (for speed).
 - expects to work behind CloudFlare - nginx has real_ip configured.

### How to start

Pull the latest image

```sh
  $ git clone https://github.com/kariedo/docker-wordpress.git
```

Create image

```sh
  $ cd docker-wordpress
  $ docker build -t wordpress-php73:latest .
```

Create container

```sh
  $ docker run --name wordpress -v /path/to/wordpress:/var/www/html -p 80:80 -p 443:443 -d wordpress-php73:latest
```

Container can work with LetsEncrypt & nginx frontend based on the following projects:

[  https://github.com/jwilder/docker-gen
]()  
[https://github.com/alastaircoote/docker-letsencrypt-nginx-proxy-companion
]()

Here the `docker-compose` example - with SSHD enabled and `www-user` SSH password set. SSH port set to `4422`.

```yaml
  services:
    example.com.wp:
      container_name: example.com.wp
      environment:
        HTTPS_METHOD: nodirect
        LETSENCRYPT_EMAIL: maintainer@example.com
        LETSENCRYPT_HOST: example.com,www.example.com
        VIRTUAL_HOST: example.com,www.example.com
        VIRTUAL_PORT: '443'
        VIRTUAL_PROTO: https
        SSHD: '1'
        SSH_PASS: changeme1234567890!Rggdx3tacRvADiM
      expose:
      - '443'
      hostname: example.com
      image: wordpress-php73:latest
      mem_limit: 1G
      ports:
      - 4422:22/tcp
      restart: always
      volumes:
      - /path/to/wordpress:/var/www/html:rw
  version: '2.0'
```

### Author

**kareido**

* [github.com/kariedo](https://github.com/kariedo/)

### License

Copyright © 2018, [kareido](https://github.com/kariedo).
Released under the [MIT License](LICENSE).
