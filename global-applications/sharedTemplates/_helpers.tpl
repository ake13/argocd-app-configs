{{- define "app.namespaces" }}
  {{- $namespaces := dict }}
  {{- range $project_index, $project := .Values.projects }}
    {{- range $application_index, $application := $project.applications }}
      {{- range $environment_index, $environment := $application.environments }}
        {{- if eq $environment.name $.envName }}
          {{- if (not $application.dontCreateNamespace) }}
            {{- $namespace := $application.namespaceOverride | default $project.name }}
            {{- $_ := $project.IstioEnvs | default list | has $environment.name | set $namespaces $namespace }}
          {{- end }}  
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- range $namespace, $useIstio := $namespaces }}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ $namespace }}
  {{- if $useIstio }}
  labels:
    istio-injection=enabled
  {{- end }}
---  
  {{- end}}
{{- end }}
