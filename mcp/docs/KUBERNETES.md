## MMCF Kubernetes adapter
### Information

Kubernetes adapter for MMCF is designed to create Kubernetes resources in existing cubernetes clusters.
YAML is used to describe the configuration of Kubernetes resources.
These configuration files are located in directories as shown below:
```yamlex
app_1/
   L k8s_deployment.yml
   L k8s_service.yml
app_2/
   L k8s_pod.yml
   L k8s_service.yml
app_3/
   L k8s_secert.yml
   L k8s_config_map.yml
   L k8s_deployment.yml
mcp/
   L k8s_secret.tf
   L k8s_config_map.tf
   L k8s_service.tf
   L k8s_deployment.tf
   L k8s_pod.tf
   L kubernetes_locals.tf
```
Kubernetes adapter modules are located in the mcp directory, in which other MMCF modules can be located.
The following Kubernetes adapter modules are currently available:

[deployment](#deployment)  
[service](#service)     
[pod](#pod)     
[secret](#secret)  
[config_map](#config_map)  
[ingress](#ingress)  
[stateful_set](#stateful_set)

### deployment

The K8S_deployment.tf module is designed to create a deployment resource in an existing Kubrenetes cluster.
The parameters for the created deployment are described in the k8s_deployment.yml file, which includes
the required metadata and spec parameters.
The structure of the deployment description for the K8S_deployment.tf module is very similar to the structure
of the deployment description that is used when working with the kubectl utility.
This allows existing deployment descriptions to be used when working with the Multi-Cloud Platform Module with minimal adaptation.
An example of a k8s_deployment.yml file describing the deployment for the K8S_deployment.tf module:

```yamlex
metadata:
  name: "terraform-examlpe"
  namespace:
  labels:
    test: "MyExampleApp"
spec:
  replicas: 2
  selector:
    match_labels:
      test: "MyExampleApp"
  template:
    metadata:
      labels:
        test: "MyExampleApp"
    spec:
      container:
        - name: "example"
          image: "nginx:1.7.8"
          resources:
            limits:
              cpu: "0.5"
              memory: "512Mi"
              requests:
                cpu: "250m"
                memory: "50Mi"
          liveness_probe:
            http_get:
              port: 80
              http_header:
                name: X-Custom-Header
                value: Awesome
            initial_delay_seconds: 3
            period_seconds: 3
```

### service

A Service is an abstraction which defines a logical set of pods and a policy by which to access them - sometimes called a micro-service.

The K8S_service.tf module is designed to create a service resource for a specified deployment or pod in an existing Kubrenetes cluster.
The parameters of the created service are described in the k8s_service.yml file, which includes the required metadata and spec parameters.
The structure of the service description for the K8S_deployment.tf module is very similar to the structure
of the service description that is used when working with the kubectl utility.
This allows existing service descriptions to be used when working with the
Multi-Cloud Platform Module with minimal adaptation.
An example of a k8s_service.yml file describing service for the K8S_service.tf module:

```yamlex
metadata:
  name: "terraform-example"
  namespace:
  labels:
    env: "test"
  generate_name:
spec:
  selector:
    test: "MyExampleApp"
  port:
    - name: "nginx-listener"
      port: 8080
      target_port: 80
  type: LoadBalancer

```

### pod

A pod is a group of one or more containers, the shared storage for those containers, and options about how to run the containers.
Pods are always co-located and co-scheduled, and run in a shared context.

The K8S_pod.tf module is designed to create a pod resource in an existing Kubrenetes cluster.
The parameters for the generated pod are described in the k8s_pod.yml file, which includes
the required metadata and spec parameters.
The structure of the pod description for the K8S_deployment.tf module is very similar to the structure
of the pod description that is used when working with the kubectl utility.
This allows existing pod definitions to be used when working with the Multi-Cloud Platform Module with minimal adaptation.
An example of a k8s_pod.yml file describing a pod for the K8S_pod.tf module:

```yamlex
metadata:
  name: "nginx-example"
  namespace:
  labels:
    app: "TestApp"
spec:
  dns_policy: None
  dns_config:
    nameservers:
      - 1.1.1.1
      - 8.8.8.8
      - 9.9.9.9
    searches:
      - example.com
    option:
      - name: ndots
        value: 1
      - name: use-vc
  env:
    name: environment
    value: test
  container:
    - name: "nginx-example"
      image: "nginx:1.7.8"
      port:
        - container_port: 8080
      liveness_probe:
        http_get:
          port: 80
          http_header:
            name: X-Custom-Header
            value: Awesome
        initial_delay_seconds: 3
        period_seconds: 3
```
### secret

The resource provides mechanisms to inject containers with sensitive information, such as passwords,
while keeping containers agnostic of Kubernetes. Secrets can be used to store sensitive information
either as individual properties or coarse-grained entries like entire files or JSON blobs.
The resource will by default create a secret which is available to any pod in the specified (or default) namespace.

The K8S_secret.tf module allows you to create a secret resource for its subsequent connection to the running container as volume.
The parameters of the created secret are described in the k8s_secret.yml file, which includes the required metadata parameter.
If necessary, transfer data from a file to the container, the file name and path to it are specified in the data_file section.
An example of the k8s_secret.yml file describing secret for the K8S_secret.tf module:

```yamlex
metadata:
  name: "mosquitto-secret-file"
  labels:
    env: "test"
type: Opaque
data_file:
  - ../mosquitto/secret.file
```

### config_map

The resource provides mechanisms to inject containers with configuration data while keeping
containers agnostic of Kubernetes. Config Map can be used to store fine-grained information like
individual properties or coarse-grained information like entire config files or JSON blobs.

The K8S_config_map.tf module allows you to create a config_map resource for its subsequent connection
to a running container as volume. The parameters of the generated config_map are described in the k8s_config_map.yml file,
which includes the required metadata parameter.
If necessary, transfer data from a file to the container, the file name and path to it are specified in the data_file section.
An example of the k8s_config_map.yml file describing the config_map for the K8S_config_map.tf module:

```yamlex
metadata:
  name: "mosquitto-config-file"
  labels:
    env: "test"
data_file:
  - ../mosquitto/mosquitto.conf
```
### ingress
The resource defines a collection of rules to allow inbound connections to reach the endpoints defined by a backend.
Configuring Ingress can load balance traffic, termanate SSL, give externall reachable urls and more
[(Terraform Docs).](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress)    
Configuration is as follows:

| Key | Type | Required | Description | Default |
|:----|:----:|:--------:|:------------|:-------:|
| `spec.backend`| map | true | Defines the service endpoint traffic will be forwarded to | none |
| `spec.rule`| map | true | Host rules to configure ingress | If not specified traffic sent to default backend|
| `spec.rule.http`| map | true if `rule` block specified | List of http selectors pointing to backend | none |
| `..http.path.path`| string | true if `http` block specified | String or POSIX regular expression matched against path of incoming request|  Sends traffic to backend |
| `..http.path.backend`| map | true if `http` block specified | Defines the service endpoint traffic will be forwarded to | none |

### stateful_set
Similarly to Deployment, StatefulSet manages Pods based on a container spec, but unlike Deployment, a statefulset maintains an identity for each pod.
Each pod has a persistent identifier that persists through rescheduling, and can claim a persistent_volume.

k8s_stateful_set.yml file is used to configure the a deploymlent of a StatefulSet resource.
**NOTE**: A template of a pod may be specified in `spec.template.spec`, which would be configured in the same way that [k8s_pod.yml](#pod) spec was.
Similarly `spec.volume_claim_template` is configured the same as [k8s_persistent_volume_claim.yml](#persitent_volume_claim)  
Attributes configuration:  

| Key | Type | Required | Description | Default |
|:----|:----:|:--------:|:------------|:-------:|
| `spec.selector.match_labels`| list | true | **(Must match pods template labels)** Label query over pods ht should match replica count | none |
| `spec.service_name`| string | true | Name of the service that governs StatefulSet **(Must exist before the StatfulSet)** | none |
| `spec.template`| map | true | Describes the pod that will be created | none |
| `spec.template.metadata`| map | true | Standard objects metadata | none |
| `spec.template.spec`| map | false | Pod spec template (see spec section of [k8s_pod.yml](#pod))  | none |
| `spec.volume_claim_template`| map | false | list of volume claims that pods can reference (see [k8s_persistent_volume_claim.yml](#persitent_volume_claim)) | none |


An example of a k8s_stateful_set.yml file configuration:
```yaml
metadata:
  name: "something"
spec:
  selector:
    match_labels:
      "k8s-app": "prometheus"
  template:
    metadata:
      namespace:
    #This section is the configured the same as k8s_pod.yml spec block
    spec:
      ...
  #This section is configured the same as k8s_persistent_volume_claim
  volume_claim_template:
     ...
```

### persistent_volume
Persistent volumes are a piece of storage in the cluster, which have a lifecycle independent of any individual pod that uses it.
Configuration for a persistent_volume is done with k8s_persistent_volume.yml.  
Attributes configuration:  

| Key | Type | Required | Description | Default |
|:----|:----:|:--------:|:------------|:-------:|
| `spec.access_modes`| list | true | All ways the volume can be mounted. Can be: `"ReadWriteOnce"`, `"ReadOnlyMany"`,`"ReadWriteMany"` | none |
| `spec.capacity`| map | true | description of persistent volumes resources and capacity | none |
| `spec.persistent_volume_source`| map | true | The specs of persistent volume, see [types](https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes) and [terraform implmentation](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume#persistent_volume_source) | none |
| `spec.storage_class_name`| string | false | Name of the persistent volumes storage class | "Standard" |
| `spec.node_affinity.required.node_selector_term`| map | true if `spec.node_affinity` | node selector term with `match_expressions` and `match_fields` attributes ORed | none |
| `match_expressions` or `match_fields`| map |false | Expression or field to map with attributes: `key`, `operator` (`"In"`, `"NotIn"`, `"Exists"`, `"DoesNotExist"`) and `values`([details](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim#values)) | none |  

An example of a k8s_persistent_volume.yml file configuration:
```yaml
metadata:
  name: "something"
spec:
  capacity:
    "storage": "10Gi"
  access_modes:
    - "ReadWriteMany"
  persistent_volume_source:
    vsphere_volume:
      volume_path: "/path"
```

### persistent_volume_claim
This adapter can request for persistent volume and claim it.
Configuration for a persistent_volume is done with k8s_persistent_volume.yml file.

Attributes configuration:  

| Key | Type | Required | Description | Default |
|:----|:----:|:--------:|:------------|:-------:|
| `metadata` | map | true | Standard kubernetes object metadata | none |
| `spec`| map | true | spec of the persistent volume owned by the cluster | none |
| `spec.access_modes`| list | true | All ways the volume can be mounted. Can be: `"ReadWriteOnce"`, `"ReadOnlyMany"`,`"ReadWriteMany"` | none |
| `spec.resources`| map | true | list of the minimum resources the volume should have with `limits` or `requests` maps defined | none |
| `spec.storage_class_name`| string | false | Name of the claims storage class | `"Standard"` |

**Note** `spec.volume_name` specifies the binding reference for the persistent volume backing the claim.
If creating a persistent volume with `k8s_persistent_volume.yml`, `volume_name` will be set to the name assigned to that resource.
Otherwise `spec.volume_name` can be specified to link to an already existing persistent volume


An example of a k8s_persistent_volume_claim.yml file configuration:
```yaml
metadata:
  name: "something"
spec:
  access_modes:
    - "ReadWriteMany"
  resources:
    requests:
      storage: "5Gi"      
  volume_name: "volume"
```
