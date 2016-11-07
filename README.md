This guide contains step-by-step how to deploy openSTF to minikube. Deploy to google/aws hosted kubernetes should be similar.


#### RethinkDB Proxy

Get rethinDB tcp host
```
$ kubectl get service rethinkdb-driver
NAME               CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
rethinkdb-driver   x.x.x.x     <none>        28015/TCP   3d
```

Edit `RETHINKDB_PORT_28015_TCP` in the `rethinkdb-proxy/rethinkdb-proxy-rc.yaml`:
```
        env:
        - name: RETHINKDB_PORT_28015_TCP
          value: "tcp://<rethinkdb-host>:28015"
```

Create pod and service
```
$ kubectl create -f rethinkdb-proxy/rethinkdb-proxy-rc.yaml
$ kubectl create -f rethinkdb-proxy/rethinkdb-proxy-service.yaml
```

#### STF App Service

Get rethinkDB Proxy tcp address
```
$ kubectl get service rethinkdb-proxy
NAME              CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
rethinkdb-proxy   x.x.x.x      <none>        28015/TCP   1m
```

Edit 'stf-services/stf-app/stf-app-rc.yaml' file:
```
        args: 
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
        env:
          - name: RETHINKDB_PORT_28015_TCP
            value: "tcp://<RETHINKDB PROXY CLUSTER IP>:28015"
          
```

Create pod and service
```
$ kubectl create -f stf-services/stf-app/stf-app-rc.yaml
$ kubectl create -f stf-services/stf-app/stf-app-service.yaml
```







