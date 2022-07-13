# Rönd example

Welcome to the Rönd example repository, here you can find some examples on how to integrate Rönd in your Kubernetes cluster as a sidecar container.

## Setup your environment

First of all, before proceeding, make sure you have access to a Kubernetes cluster, it may be a full-fledged cluster or local cluster, it doesn't matter, the only thing you have to be sure is that you can create new objects (specifically `Deployment`, `ConfigMap` and `Service`) in it and to apply them in the proper namespace (the `default` namespace is enough).

For completeness we will continue the example assuming you are using a local cluster created with [Kind](https://kind.sigs.k8s.io).

### Install kind

To install Kind head up to the [official guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation), there are a few commands you may have to run, for example if you have macOS you can simply run:

```sh
brew install kind
```

After installation is completed, create a new cluster by using the following command:

```sh
kind create cluster --name=rond-example --config kind.config.yaml
```

Note: we are creating a new cluster using a custom configuration that already exposes the application on NodePort `30000`, if you are using something else to run your cluster, make sure the correct port is exposed on your local machine, otherwise you may have no access to the application Pod and you may be forced to use `port-forward` to access it.

For further information check out [this guide](https://kind.sigs.k8s.io/docs/user/quick-start/#creating-a-cluster).

## Boot the example

You can boot the application by running the following script:

```sh
sh boot.sh
```

otherwise, if you want to manually patch the configuration files you can apply them one by one (which is what the script does):

```sh
kubectl apply -f ./kubefiles/routes.configmap.yaml
kubectl apply -f ./kubefiles/policies.configmap.yaml
kubectl apply -f ./kubefiles/application.service.yaml
kubectl apply -f ./kubefiles/application.deployment.yaml
```

Please note that we are creating everything in the `default` namespace so be sure that's right for you, otherwise you'll have to run all the commands selecting the proper namespace.

## What's inside the application

The application is all defined in the `kubefiles` directory and it is composed by a single `Deployment` with two containers, one is Rönd the other one is a simple [echo-service](https://github.com/davidebianchi/echo-service) that replies to any request with a body containing all the request details (headers, body, params, etc); this allows us to inspect how the request is forwarded from Rönd to the application service.

If you want to read policies check out the [kubefiles/policies.configmap.yaml](./kubefiles/policies.configmap.yaml) file, if you want to see how the routes are configured check out the [kubefiles/routes.configmap.yaml](./kubefiles/routes.configmap.yaml) file instead.

## Try it out

The application revoles around four API each one using a specific policy to manage access

| Endpoint                 | Policy               |
|--------------------------|----------------------|
| /hello                   | allow_all            |
| /secret-hello            | verify_authorization |
| /generate-request-filter | data_filter          |
| /basic-info              | basic_info_parser    |

The examples below show how to use the example with `curl` but a [Postman](https://www.postman.com/) collection is also available [here](./rond-example.postman_collection.json).

### /hello

Everyone has access to the `/hello` API, since it uses the `allow_all` policy which is always thruthy.

#### Use it

```sh
curl http://localhost:30000/hello
```

| Status code | Payload               |
|-------------|-----------------------|
| 200         | Complete request info |

### /secret-hello

This API uses the `verify_authorization` policy which verifies that a specific header (`authorization`) is set with the proper value (`bearer 123456`). For this reason, the API invocations will be rejected unless the `Authorization` header is correctly provided.

#### Use it

##### Rejected examples

```sh
curl http://localhost:30000/secret-hello
curl http://localhost:30000/secret-hello -H 'Authorization: bearer 789101'
```

| Status code | Payload        |
|-------------|----------------|
| 403         | Error response |

##### Allowed example

```sh
curl localhost:30000/secret-hello -H 'Authorization: bearer 123456'
```

| Status code | Payload               |
|-------------|-----------------------|
| 200         | Complete request info |

### /generate-request-filter

This API uses the `data_filter` policy, which generates a MongoDB query to be used in order to only retrieve authorized data from the database.

To view the generated query check out the response body from the API invocation, you'll find that the `headers` object also contains a new header `x-acl-rows` which has been created by Rönd.

Note: the header content should then be handled by your application to properly parse the query and use it to apply more filters.

#### Use it

```sh
curl localhost:30000/generate-request-filter
```

| Status code | Payload                                   |
|-------------|-------------------------------------------|
| 200         | Complete request info + x-acl-rows header |

### /basic-info

This API uses the `basic_info_parser` which modified the response body to only supply to the client the desired information, in this case only `path` and `method` fields are returned.

Please note that this API actually has two different policies, it uses the `verify_authorization` during the request flow (before forwarding the request to the application), while the `basic_info_parser` is used to tamper the response body during the response flow (when the application has sent its response to the client). For this reason the authorization header is requried as for the [`/secret-hello`](#secret-hello) example.

#### Use it

```sh
curl localhost:30000/basic-info -H 'authorization: bearer 123456'
```

| Status code | Payload      |
|-------------|--------------|
| 200         | {path, name} |

### What about unknown routes?

If a route has not been registered Rönd will immediately reject the API invocation with `403` status code

```sh
curl http://localhost:30000/unknown-path
```
