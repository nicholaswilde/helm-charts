# photoshow

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 48aabb98](https://img.shields.io/badge/AppVersion-48aabb98-informational?style=flat-square)

A gallery software at its easiest, it doesn't even require a database.

## Requirements
* [mysql](https://github.com/nicholaswilde/helm-charts/wiki/Databases)

## Dependencies

| Repository | Name | Version |
|------------|------|---------|
| https://nicholaswilde.github.io/helm-charts/ | common | ~0.1.13 |

## TL;DR
```console
$ helm repo add nicholaswilde https://nicholaswilde.github.io/helm-charts/
$ helm repo update
$ helm install photoshow nicholaswilde/photoshow
```

## Installing the Chart
To install the chart with the release name `photoshow`:
```console
helm install photoshow nicholaswilde/photoshow
```

## Uninstalling the Chart
To uninstall the `photoshow` deployment:
```console
helm uninstall photoshow
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Read through the [values.yaml](./values.yaml) file. It has several commented out suggested values.
Other values may be used from the [values.yaml](../common/values.yaml) from the [common library](../common).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,
```console
helm install photoshow \
  --set env.TZ="America/New York" \
    nicholaswilde/photoshow
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart.
For example,
```console
helm install photoshow nicholaswilde/photoshow -f values.yaml
```

## Troubleshooting
See [Wiki](https://github.com/nicholaswilde/helm-charts/wiki/Troubleshooting).

## Author
This project was started in 2021 by [Nicholas Wilde](https://github.com/nicholaswilde).

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)