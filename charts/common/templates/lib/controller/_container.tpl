{{- /*
The main container included in the controller.
*/ -}}
{{- define "common.controller.mainContainer" -}}
- name: {{ include "common.names.fullname" . }}
  image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  {{- with .Values.args }}
  args: {{ . }}
  {{- end }}
  {{- with .Values.command }}
  command: {{ . }}
  {{- end }}
  {{- with .Values.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if or .Values.env .Values.secret }}
  envFrom:
  {{- if .Values.env }}
    - configMapRef:
        name: {{ include "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.secret }}
    - secretRef:
        name: {{ include "common.names.fullname" . }}
  {{- end }}
  {{- end }}
  {{- include "common.controller.ports" . | trim | nindent 2 }}
  volumeMounts:
  {{- range $index, $PVC := .Values.persistence }}
  {{- if $PVC.enabled }}
  - mountPath: {{ $PVC.mountPath }}
    name: {{ $index }}
  {{- end }}
  {{- end }}
  {{- if .Values.additionalVolumeMounts }}
    {{- toYaml .Values.additionalVolumeMounts | nindent 2 }}
  {{- end }}
  {{- include "common.controller.probes.tcpSocket" . | nindent 2 }}
  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
