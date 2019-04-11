# Density

This the Helm Chart for app_a and app_b.

## What is Helm?

Helm is a package manager for Kubernetes, where the micro-services are the packages.
Think of Helm as the apt-get, yum, homebrew, or npm of Kubernetes.

Helm makes it incredibly easy to version your deployments by using Helm Charts.
Helm Charts are YAML templates that define how to package, release, deploy,
delete, upgrade and even rollback your application.

### Requirements

- MacOS: Install Helm via HomeBrew:
  - $ `brew install kubernetes-helm`

- Windows: Install via [Chocolatey](https://chocolatey.org/):
  - $ `choco install kubernetes-helm`

- Linux: Install via Snap:
  - $ `sudo snap install helm --classic`

- Optional: Install [Docker Desktop](https://www.docker.com/products/docker-desktop)

### The `ingress.yaml` file

The `ingress.yaml` file contains all the forwarding rules to each service. This is assuming you've setup some sort of ingress controller to control the routes. When you add-on a service or a new route you will simply add to this `ingress.yaml` file and include the new path you want to forward. The ingress controller will take care of route and forward any request to that particular service.

### The `values.yaml` file

The `values.yaml` file contains all the key/values that the application and it's micro-services
uses. These values are sectioned off by micro-service name. For example:

    app_a:
        name: "frontend"
        replicaCount: 4
        ...
    app_b:
        enabled: true
        name: "backend"
        replicaCount: 4
        ...

If you need to add a new value to an application, please add it under the micro-service name key/value field. You can then call it by using a template directive. A template directive is a way to inject values into the Helm templates by using curly brackets `{{` and `}}`. For example, if I wanted to add a new key/value `drink: "coffee"` to the app_a application, I would add it under the `app_a` key:

    # app_a ENV VARS
    app_a:
        name: "frontend"
        replicaCount: 1
        repository: your-container-registry-here/app_a
        drink: "coffee"
        ...

Now I could call it anywhere within the Helm Chart like this:
    `{{ .Values.app_a.drink }}`

**NOTE: We currently have three values files. One for dev/sandbox environments (`values.yaml`), one for staging (`stg-values.yaml`), and one for production(`prod-values.yaml`). Use the appropriate values file per environment.**

**NOTE: The `values.yaml` file will only take dots(`.`) and underscores(`_`) as YAML keys. Do NOT use dashes.**

### The Templates directory

Templates generate manifest files, which are YAML-formatted resource descriptions that Kubernetes can understand. The `templates` directory contains all of the Helm chart templates for our micro-service.

- `_helpers.tpl`: This is a place to put template helpers that you can re-use throughout the chart.

- `<name-of-your-service>-cm.yaml`: In Kubernetes, a ConfigMap is simply a container for storing configuration data. Other things, like pods, can access the data in a ConfigMap. We use the `data:` code block to iterate through the `values.yaml` file and populate key/values for us by using this snippet of code:

        data:
        {{- range $key, $value := $.Values.app_a.env }}
        {{ $key }}: {{ $value | quote }}
        {{- end }}

    `range` is a go Function that iterates through items. Think of it as a `for` loop. The `| quote` section quotes any values that are injected.

- `<name-of-your-service>-deploy.yaml`: A basic manifest for creating a Kubernetes deployment. This file contains items that will directly affect your deployments. These include:
  - `Liveness Probes`: Kubernetes health checks to see whether the service is alive/dead.
  
  - `Readiness Probes`: Another healthcheck. Is the application ready to start listening or taking connections?
  
  - `Application Labels`: Used by Kubernetes to identify this resource. It is also useful to expose to operators for the purpose of querying the system.
  
  - `Ports`: The port(s) that the container will listen on.
  
  - `imagePullSecrets`: username/password for container registry. This is abstracted and supplied by using Kubernetes secrets. Check the kubernetes secrets to find out more.

- `<name-of-your-service>-svc.yaml`: A basic manifest for creating a service endpoint for your deployment.

- `NOTES.txt`: This is Helm’s tool for providing instructions to your chart users. At the end of a `chart install` or `chart upgrade`, Helm can print out a block of helpful information for users.

**NOTE:** *You will rarely have to change any of the template files within the chart since most have already been created. If you do need to update a value within a template you should be able to do it via the `values.yaml` file. Make sure you select the right one per your environment (dev/stg/prod).*

You can find more info about Helm templating and charts [here](https://docs.helm.sh/chart_template_guide)

### Horizontal Pod Autoscaling

The Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment or replica set based on observed CPU utilization (or, with custom metrics support, on some other application-provided metrics).

The `hpa.yaml` file shows an example of how to horizontally scale your application using resource metrics like CPU utilization as well as other customer metrics (requests-per-second).

The `hpa.yaml` shows the Kubernetes HorizontalPodAutoscaler. It attempts to ensure that each pod is consuming roughly 50% of its requested CPU, serving 1000 packets per second, and that all pods behind the main-route Ingress were serving a total of 10000 requests per second. This metric can be adjusted but must be followed through thouroughly to ensure your Kubernetes cluster has enough resources (Memory/CPU/Storage/etc.).

### Sandbox Environments

To setup a sandbox environment run the following command:

    $helm install <path-to-your-chart> --namespace my-sandbox-namespace

This will have kubernetes assign a random name to your release deployment and show the output of the release via STDOUT. Congratulations! Your new environment is up and running!

### Troubleshooting

A few commands will come in handy when trying to troubleshoot your Helm Chart:

A helm linter for your chart templates:

- `helm lint <Chart-Name>`

A great way to have the server render your templates, then return the resulting manifest file:

- `helm install --dry-run --debug <Chart-Name>`

More debugging info can be found here: [Debugging Helm Charts](https://docs.helm.sh/chart_template_guide/#debugging-templates)