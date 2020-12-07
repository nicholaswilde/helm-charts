{{/*
Main entrypoint for the common library chart. It will render all underlying templates based on the provided values.
*/}}
{{- define "common.all" -}}
  {{- /* Merge the local chart values and the common chart defaults */ -}}
  {{- include "common.values.setup" . }}
  {{- /* Enable OpenVPN VPN add-on if required */ -}}
  {{- if .Values.addons.vpn.enabled }}
    {{- include "common.addon.vpn" . }}
  {{- end -}}
  {{- /* Build the templates */ -}}
  {{- include "common.pvc" . }}
  {{- print "---" | nindent 0 -}}
  {{- if .Values.env -}}
    {{- include "common.configmap" . }}
    {{- print "---" | nindent 0 -}}
  {{- end -}}
  {{- if .Values.secret -}}
    {{- include "common.secret" . }}
    {{- print "---" | nindent 0 -}}
  {{- end -}}
  {{- if .Values.serviceAccount.create -}}
    {{- include "common.serviceAccount" . }}
    {{- print "---" | nindent 0 -}}
  {{- end -}}
  {{- if eq .Values.controllerType "deployment" }}
    {{- include "common.deployment" . | nindent 0 }}
  {{ else if eq .Values.controllerType "daemonset" }}
    {{- include "common.daemonset" . | nindent 0 }}
  {{ else if eq .Values.controllerType "statefulset"  }}
    {{- include "common.statefulset" . | nindent 0 }}
  {{- end -}}
  {{- if .Values.service.enabled }}
    {{- print "---" | nindent 0 -}}
    {{ include "common.service" . | nindent 0 }}
  {{- end -}}
  {{- if .Values.ingress.enabled }}
    {{- print "---" | nindent 0 -}}
    {{ include "common.ingress" .  | nindent 0 }}
  {{- end -}}
  {{- if .Values.rbac }}
    {{- print "---" | nindent 0 -}}
    {{ include "common.rbac" .  | nindent 0 }}
  {{- end -}}
{{- end -}}
