# installer
This is a helm chart for [jpillora's](https://github.com/jpillora) [installer](https://github.com/jpillora/installer)

Quickly install pre-compiled binaries from Github releases.

The default values and container images used in this chart will allow for running in a multi-arch cluster (amd64, arm, arm64)

## TL;DR;

```shell
$ helm repo add nicholaswilde http://nicholaswilde.github.io/helm-charts
$ helm install installer nicholaswilde/installer
```

## Installing the Chart

To install the chart with the release name `installer`:

```console
helm install installer nicholaswilde/installer
```

## Uninstalling the Chart

To uninstall/delete the `installer` deployment:

```console
helm uninstall installer
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Read through the [values.yaml](https://github.com/nicholaswilde/helm-charts/blob/main/charts/installer/values.yaml) file. It has several commented out suggested values.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install installer \
    nicholaswilde/installer
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install installer -f values.yaml nicholaswilde/installer
```
