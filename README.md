# Rönd example

Welcome to the example ....


## Setup your environment

You need a kubernetes instance running locally, you can use whatever you prefer, we will continue the example assuming you are using Kind.

### Install kind

To install kind head up to the [official guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

For example if you have macOS you can simply run

```sh
brew install kind
```

After installation is completed, simply run you cluster by following [this guide](https://kind.sigs.k8s.io/docs/user/quick-start/#creating-a-cluster)

```sh
kind create cluster --name=rond-example --config kind.config.yaml
```

Note: we provide a kind cluster configuration that already exposes the application on NodePort `30000`, if you are using something else to run your cluster, make sure the correct port is expose on your local machine, otherwise you have to use port-forward to access the application Pod.

## Boot the example

You can boot the application by simply running the following script

```sh
sh boot.sh
```

otherwise, if you want to manually patch the configuration files you can apply them one by one:

```sh
kubectl apply -f ./kubefiles/routes.configmap.yaml
kubectl apply -f ./kubefiles/policies.configmap.yaml
kubectl apply -f ./kubefiles/application.service.yaml
kubectl apply -f ./kubefiles/application.deployment.yaml
```

## What's inside the application

there is rond and there is the echo service which replies with a body containing all the request details (body,headers,etc); this allows us to inspect how the request is forwarded from rond to the application service

## Try it out

api/policy mapping table

postman collection to download etc

### /hello

Everyone has access to the `/hello` API, since it uses the `allow_all` policy

**Example**

```sh
curl http://localhost:30000/hello
```

### /secret-hello

The API will be rejected unless the `Authorization` header is provided with the following value `bearer 123456`; checkout the `verify_authorization` policy for further information

**Example of a failing invocation**

```sh
curl http://localhost:30000/secret-hello
curl http://localhost:30000/secret-hello -H 'Authorization: bearer 789101'
```

**Example of a correct invocation**

```sh
curl localhost:30000/secret-hello -H 'Authorization: bearer 123456'
```

### /generate-request-filter

This API uses the `data_filter` policy, which generates a MongoDB query to be used in order to only retrieve authorized data from the database. Check out the response body from the API invocation, you'll find that the `headers` object also contains a new header `x-acl-rows` which has been created by rond...

This value should then be handled by your application to properly parse the query and use it to apply more filters.

### /basic-info

This API uses the `basic_info_parser` which modified the response body to only supply to the client the desired information, in this case only `path` and `method` fields are returned.

```sh
curl localhost:30000/basic-info -H 'authorization: bearer 123456'
```

### unregistered route

If a route has not been registered rond will immediately reject the API invocation with `403` status code

```sh
curl http://localhost:30000/unknown-path
```
