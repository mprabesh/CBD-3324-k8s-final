{{/*
Expand the name of the chart.
*/}}
{{- define "blog-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "blog-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "blog-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "blog-app.labels" -}}
helm.sh/chart: {{ include "blog-app.chart" . }}
{{ include "blog-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
project: blog-k8s-deployment
maintainer: {{ .Values.global.maintainer | replace " " "-" | lower }}
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "blog-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "blog-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "blog-app.frontend.selectorLabels" -}}
{{ include "blog-app.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "blog-app.backend.selectorLabels" -}}
{{ include "blog-app.selectorLabels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Redis selector labels
*/}}
{{- define "blog-app.redis.selectorLabels" -}}
{{ include "blog-app.selectorLabels" . }}
app.kubernetes.io/component: redis
{{- end }}

{{/*
MongoDB selector labels
*/}}
{{- define "blog-app.mongodb.selectorLabels" -}}
{{ include "blog-app.selectorLabels" . }}
app.kubernetes.io/component: mongodb
{{- end }}

{{/*
Frontend service account name
*/}}
{{- define "blog-app.frontend.serviceAccountName" -}}
{{- if .Values.frontend.serviceAccount.create }}
{{- default (printf "%s-frontend" (include "blog-app.fullname" .)) .Values.frontend.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.frontend.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Backend service account name
*/}}
{{- define "blog-app.backend.serviceAccountName" -}}
{{- if .Values.backend.serviceAccount.create }}
{{- default (printf "%s-backend" (include "blog-app.fullname" .)) .Values.backend.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.backend.serviceAccount.name }}
{{- end }}
{{- end }}
