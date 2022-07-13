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


## Try it out


### API to invoke and policy examplation


curl 

postman collection etc
