# sickgear

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: release_0.23.22](https://img.shields.io/badge/AppVersion-release_0.23.22-informational?style=flat-square)

Provides management of TV shows and/or Anime, it detects new episodes, links downloader apps, and more

## Dependencies

| Repository | Name | Version |
|------------|------|---------|
| https://nicholaswilde.github.io/helm-charts/ | common | ~0.1.13 |

## TL;DR
```console
$ helm repo add nicholaswilde https://nicholaswilde.github.io/helm-charts/
$ helm repo update
$ helm install sickgear nicholaswilde/sickgear
```

## Installing the Chart
To install the chart with the release name `sickgear`:
```console
helm install sickgear nicholaswilde/sickgear
```

## Uninstalling the Chart
To uninstall the `sickgear` deployment:
```console
helm uninstall sickgear
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Read through the [values.yaml](./values.yaml) file. It has several commented out suggested values.
Other values may be used from the [values.yaml](../common/values.yaml) from the [common library](../common).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,
```console
helm install sickgear \
  --set env.TZ="America/New York" \
    nicholaswilde/sickgear
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart.
For example,
```console
helm install sickgear nicholaswilde/sickgear -f values.yaml
```

## Troubleshooting
See [Wiki](https://github.com/nicholaswilde/helm-charts/wiki/Troubleshooting).

## Author
This project was started in 2021 by [Nicholas Wilde](https://github.com/nicholaswilde).

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)