{{/*
Liveness/readiness/startup probes based on tcpSocket checks.
*/}}
{{- define "common.controller.probes.tcpSocket" -}}
{{- if and .Values.probes.liveness.enabled .Values.service.enabled -}}
livenessProbe:
  tcpSocket:
    port: {{ .Values.service.port.name }}
  initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds }}
  failureThreshold: {{ .Values.probes.liveness.failureThreshold }}
  timeoutSeconds: {{ .Values.probes.liveness.timeoutSeconds }}
{{- end }}
{{- if and .Values.probes.readiness.enabled .Values.service.enabled }}
readinessProbe:
  tcpSocket:
    port: {{ .Values.service.port.name }}
  initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds }}
  failureThreshold: {{ .Values.probes.readiness.failureThreshold }}
  timeoutSeconds: {{ .Values.probes.readiness.timeoutSeconds }}
{{- end }}
{{- if and .Values.probes.startup.enabled .Values.service.enabled }}
startupProbe:
  tcpSocket:
    port: {{ .Values.service.port.name }}
  initialDelaySeconds: {{ .Values.probes.startup.initialDelaySeconds }}
  failureThreshold: {{ .Values.probes.startup.failureThreshold }}
  periodSeconds: {{ .Values.probes.startup.periodSeconds }}
{{- end }}
{{- end }}
