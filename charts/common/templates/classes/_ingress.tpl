{{/*
This template serves as a blueprint for all Ingress objects that are created 
within the common library.
*/}}
{{- define "common.classes.ingress" -}}
{{- $version := include "common.capabilities.ingress.apiVersion" . -}}
{{- $ingressName := include "common.names.fullname" . -}}
{{- $values := .Values.ingress -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.ingress -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}
{{- if hasKey $values "nameSuffix" -}}
  {{- $ingressName = printf "%v-%v" $ingressName $values.nameSuffix -}}
{{ end -}}
apiVersion: {{ include "common.capabilities.ingress.apiVersion" . }}
kind: Ingress
metadata:
  name: {{ $ingressName }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  {{- with $values.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if $values.tls }}
  tls:
    {{- range $values.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
  {{- range $values.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              {{- if ne $version "networking.k8s.io/v1" }}
              serviceName: {{ .backend.serviceName }}
              servicePort: {{ .backend.servicePort }}
              {{- else }}
              service:
                name: {{ .backend.serviceName }}
                port:
                  number: {{ .backend.servicePort  }}
              {{- end }}
          {{- end }}
  {{- end }}
{{- end }}
