# helm-charts
My collection of [Helm](https://helm.sh/) charts.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add nicholaswilde https://nicholaswilde.github.io/helm-charts/
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

## License

[Apache 2.0 License](./LICENSE)

## Author
This project was started in 2020 by Nicholas Wilde.
