# Helm Charts
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/nicholaswilde)](https://artifacthub.io/packages/search?repo=nicholaswilde)
[![Release Charts](https://github.com/nicholaswilde/helm-charts/workflows/Release%20Charts/badge.svg)](https://github.com/nicholaswilde/helm-charts/actions)
[![GitHub](https://img.shields.io/github/license/nicholaswilde/helm-charts)](https://github.com/nicholaswilde/helm-charts/blob/main/LICENSE)
[![GitHub all releases](https://img.shields.io/github/downloads/nicholaswilde/helm-charts/total)](https://github.com/nicholaswilde/helm-charts/releases)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fnicholaswilde%2Fhelm-charts.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fnicholaswilde%2Fhelm-charts?ref=badge_shield)

My collection of [Helm](https://helm.sh/) charts.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add nicholaswilde https://nicholaswilde.github.io/helm-charts/
helm repo update
```
You can then run `helm search repo nicholaswilde` to see the charts.

### Pre-commit hook

If you want to automatically generate `README.md` files with a pre-commit hook, make sure you
[install the pre-commit binary](https://pre-commit.com/#install), and add a [.pre-commit-config.yaml file](./.pre-commit-config.yaml)
to your project. Then run:

```bash
pre-commit install
pre-commit install-hooks
```
## Charts

See [artifact hub](https://artifacthub.io/packages/search?repo=nicholaswilde) for a complete list.

## Development

See [Wiki](https://github.com/nicholaswilde/helm-charts/wiki/Development).

## Troubleshooting

See [Wiki](https://github.com/nicholaswilde/helm-charts/wiki/Troubleshooting).

## Inspiration

Inspiration for this repository has been taken from [k8s-at-home/charts](https://github.com/k8s-at-home/charts).

## Contributing

See [Contributing](./CONTRIBUTING.md)

## License

[Apache 2.0 License](./LICENSE)

## Author
This project was started in 2020 by [Nicholas Wilde](https://github.com/nicholaswilde/).
