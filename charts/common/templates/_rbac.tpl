{{/*
The ClusterRole & ClusterRoleBinding objects to be created.
*/}}
{{- define "common.rbac" -}}
{{- $values := .Values.rbac -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ include "common.names.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
roleRef:
  name: {{ template "common.names.fullname" . }}
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
subjects:
  - name: {{ template "common.names.fullname" . }}
    namespace: {{ .Release.Namespace }}
    kind: ServiceAccount
  {{- with $values.additionalSubjects }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- print ("---") | nindent 0 -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ template "common.names.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
rules:
  {{- with $values.rules }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
