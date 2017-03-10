This guide contains step-by-step an example how to deploy openSTF to kubernetes <http://kubernetes.io/>.

#### RethinkDB

First, we need to have RethinkDB server. The below script just for an example, not recommended for production. For further information, you can refer to https://rethinkdb.com/docs/security/

```
$kubectl create -f rethinkdb/driver-service.yaml
$kubectl create -f rethinkdb/rc.yaml
$kubectl create -f rethinkdb/admin-pod.yaml
$kubectl create -f rethinkdb/admin-service.yaml
```

Find the admin service to get the ip
```
$kubectl get service rethinkdb-admin

NAME              CLUSTER-IP   EXTERNAL-IP        PORT(S)    AGE
rethinkdb-admin   xx.xx.xx.xx  xx.xx.xx.xx        8080/TCP   12d
```

Now, you can open RethinkDB admin dashboard to http://<external-ip>:8080

If you use minikube, you need to get the node port using this command:
```
minikube service rethinkdb-admin url

```


#### RethinkDB Proxy

Create pod and service
```
$ kubectl create -f rethinkdb-proxy/rethinkdb-proxy-rc.yaml
$ kubectl create -f rethinkdb-proxy/rethinkdb-proxy-service.yaml
```

Check pod and service
```
$ kubectl get pod -l app=rethinkdb-proxy
NAME                    READY     STATUS    RESTARTS   AGE
rethinkdb-proxy-tqljl   1/1       Running   0          1m

$ kubectl get service rethinkdb-proxy
NAME              CLUSTER-IP     EXTERNAL-IP   PORT(S)     AGE
rethinkdb-proxy   x.x.x.x        <none>        28015/TCP   1m
```

#### STF RETHINKDB MIGRATE

Create pod
```
$ kubectl create -f stf-services/stf-migrate/stf-migrate-rc.yaml
```
wait until all table created, then delete the pod

```
$ kubectl delete rc stf-migrate
```

#### STF STORAGE

Create pod and service
```
$ kubectl create -f stf-services/stf-storage-temp/stf-storage-temp-rc.yaml
$ kubectl create -f stf-services/stf-storage-temp/stf-storage-temp-service.yaml
```

#### STF APK STORAGE

Edit domain name in the 'stf-services/stf-storage-plugin-apk/stf-storage-plugin-apk-rc.yaml' file:
```
        args: 
        - storage-plugin-apk
        - --port
        - "3000"
        - --storage-url
        - "https://<YOUR DOMAIN HERE>>"
          
```

Create pod and service
```
$ kubectl create -f stf-services/stf-storage-plugin-apk/stf-storage-plugin-apk-rc.yaml
$ kubectl create -f stf-services/stf-storage-plugin-apk/stf-storage-plugin-apk-service.yaml
```


#### STF IMAGE STORAGE

Edit domain name in the 'stf-services/stf-storage-plugin-image/stf-storage-plugin-image-rc.yaml' file:
```
        args: 
        - storage-plugin-image
        - --port
        - "3000"
        - --storage-url
        - "https://<YOUR DOMAIN HERE>"
          
```

Create pod and service
```
$ kubectl create -f stf-services/stf-storage-plugin-image/stf-storage-plugin-image-rc.yaml
$ kubectl create -f stf-services/stf-storage-plugin-image/stf-storage-plugin-apk-service.yaml
```

#### STF TRIPROXY APP

Create pod and service
```
$ kubectl create -f stf-services/stf-triproxy-app/stf-triproxy-app-rc.yaml
$ kubectl create -f stf-services/stf-triproxy-app/stf-triproxy-app-service.yaml
```

#### STF TRIPROXY DEV

Create pod and service
```
$ kubectl create -f stf-services/stf-triproxy-dev/stf-triproxy-dev-rc.yaml
$ kubectl create -f stf-services/stf-triproxy-dev/stf-triproxy-dev-service.yaml
```

#### STF PROCESSOR

Create pod
```
$ kubectl create -f stf-services/stf-processor/stf-processor-rc.yaml
```

#### STF REAPER

Create pod
```
$ kubectl create -f stf-services/stf-reaper/stf-reaper-rc.yaml
```

#### STF WEBSOCKET

Edit secret key and domain name in the 'stf-services/stf-websocket/stf-websocket-rc.yaml' file:
```
        args: 
        - websocket
        - --secret
        - "<YOUR SECRET HERE>"
        - --port
        - "3000"
        - --storage-url
        - "http://<YOUR DOMAIN HERE>"
          
```
 

Create pod and service
```
$ kubectl create -f stf-services/stf-triproxy-dev/stf-triproxy-dev-rc.yaml
$ kubectl create -f stf-services/stf-triproxy-dev/stf-triproxy-dev-service.yaml
```

#### STF API

Edit secret in the 'stf-services/stf-api/stf-api-rc.yaml' file:
```
        args: 
        - api
        - --secret
        - "<YOUR SECRET HERE>"
        - --port
        - "3000"
          
```

Create pod and service
```
$ kubectl create -f stf-services/stf-api/stf-api-rc.yaml
$ kubectl create -f stf-services/stf-api/stf-api-service.yaml
```


#### STF APP

Edit secret and domain name in the 'stf-services/stf-app/stf-app-rc.yaml' file:
```
        args: 
          - app
          - --secret 
          - "<YOUR SECRET HERE>" 
          - --port
          - "3000"
          - --auth-url 
          - "http://<YOUR APP DOMAIN>/auth/mock/"
          - --websocket-url
          - "wss://<YOUR APP DOMAIN>/"
          
```

Create pod and service
```
$ kubectl create -f stf-services/stf-websocket/stf-websocket-rc.yaml
$ kubectl create -f stf-services/stf-websocket/stf-websocket-service.yaml
```

#### STF AUTH

Edit secret and domain name in the 'stf-services/stf-auth/stf-auth-rc.yaml' file:
```
        args: 
        - auth-mock
        - --secret
        - "<YOUR SECRET HERE>"
        - --port
        - "3000"
        - --app-url
        - "http://<YOUR DOMAIN HERE>/"
          
```

Create pod and service
```
$ kubectl create -f stf-services/stf-auth/stf-basic-auth-rc.yaml
$ kubectl create -f stf-services/stf-websocket/stf-auth-service.yaml
```

You also can use another auth type with similar config.


#### NGINX

Get ip of the stf services, then update the nginx.conf based on those ips.
```
$kubectl get service stf-app
NAME      CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
stf-app   x.x.x.x        <none>        3100/TCP   30m

$kubectl get service stf-auth
NAME      CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
stf-auth   x.x.x.x        <none>        3100/TCP   30m

$kubectl get service stf-apk-storage
NAME              CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
stf-apk-storage   x.x.x.x        <none>        3100/TCP   30m

$kubectl get service stf-img-storage
NAME              CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
stf-amg-storage   x.x.x.x        <none>        3100/TCP   30m

$kubectl get service stf-storage
NAME          CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
stf-storage   x.x.x.x        <none>        3100/TCP   30m

$kubectl get service stf-websocket
NAME            CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
stf-websocket   x.x.x.x        <none>        3100/TCP   30m

$kubectl get service stf-api
NAME      CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
stf-api   x.x.x.x        <none>        3100/TCP   30m
```

Edit the nginx.conf. Don't forget to edit the provider public ip.

Build the nginx docker
```
$docker build -t <username>/stf-nginx:latest .
```

Push the docker image to your docker hub

Edit the image name in the nginx/stf-nginx-rc.yaml
```
containers:
      - name: stf-nginx
        image: <username>/stf-nginx:latest
```

Create pod and service
```
$ kubectl create -f nginx/stf-nginx-rc.yaml
$ kubectl create -f nginx/stf-nginx-service.yaml
```


#### STF PROVIDER

- Attach the device to the provider server.
- Run adb server on the server
- Run stf provider

```
$ stf provider --connect-sub "tcp://<TRIPROXY DEV HERE>:7250" \
  --connect-push "tcp://<TRIPROXY DEV HERE>:7270" --storage-url "http://<YOUR DOMAIN HERE>" \
  --min-port 15000 --max-port 25000 --name "<PROVIDER NAME>" --public-ip "<PROVIDER PUBLIC IP>"
```









