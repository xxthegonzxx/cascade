{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "density.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "density.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "density.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a pre-defined template for app_a ENV VARS and iterate through it.
*/}}
{{- define "app_a.cm_template" -}}
    {{- range $key, $value := $.Values.app_a.env }}
        - name: {{ $key }}
          valueFrom:
            configMapKeyRef:
            {{- if ($.Values.environment) and eq $.Release.Name $.Values.environment }}
              name: "{{ $.Values.environment }}-cm"
            {{- else if (eq $.Release.Name "dev-density") }}
              name: "{{ $.Release.Name }}-cm"
            {{- else }}
              name: "{{ $.Release.Name }}-{{ $.Values.app_a.name }}-cm"
            {{- end }}
              key: {{ $key }}
    {{- end }}
{{- end -}}

{{/*
Create a pre-defined template for app_b ENV VARS and iterate through it.
*/}}
{{- define "app_b.cm_template" -}}
    {{- range $key, $value := $.Values.app_b.env }}
        - name: {{ $key }}
          valueFrom:
            configMapKeyRef:
            {{- if ($.Values.environment) and eq $.Release.Name $.Values.environment }}
              name: "{{ $.Values.environment }}-cm"
            {{- else if (eq $.Release.Name "dev-density") }}
              name: "{{ $.Release.Name }}-cm"
            {{- else }}
              name: "{{ $.Release.Name }}-{{ $.Values.app_b.name }}-cm"
            {{- end }}
              key: {{ $key }}
    {{- end }}
{{- end -}}